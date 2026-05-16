import re
import sys
import traceback
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union

from PyQt5.QtCore import QVariant
from PyQt5.QtWidgets import (
    QApplication,
    QButtonGroup,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QMessageBox,
    QPushButton,
    QRadioButton,
    QSlider,
    QListWidget,
    QVBoxLayout,
    QWidget,
)

try:
    from pyswip import Prolog
except Exception as exc:  # pragma: no cover - environment specific
    Prolog = None
    IMPORT_ERROR = exc
else:
    IMPORT_ERROR = None


AnswerValue = Union[str, int]


@dataclass
class Question:
    qid: str
    feature: str
    input_type: str
    context: str
    enum_values: Optional[List[str]] = None


_SESSION_MOD = "gui_session"
_QID_RE = re.compile(r"^q_[a-z0-9_]+$")
_ATOM_RE = re.compile(r"^[a-z][a-z0-9_]*$")
# Dialog kończy się, gdy dowolny kraj ma pewność ściśle większą niż ten próg.
CONFIDENCE_WIN_THRESHOLD = 0.9


def _unwrap_qvariant(raw: Any) -> Any:
    if isinstance(raw, QVariant):
        if raw.type() == QVariant.Invalid:  # type: ignore[attr-defined]
            return None
        return raw.value()
    return raw


def _prolog_text(x: Any) -> str:
    """Normalize pyswip Atom / PyQt types to plain str for Prolog source fragments."""
    x = _unwrap_qvariant(x)
    if x is None:
        return ""
    try:
        from pyswip.easy import Atom  # type: ignore[import-untyped]

        if isinstance(x, Atom):
            return str(getattr(x, "value", x))
    except Exception:
        pass
    if isinstance(x, bytes):
        return x.decode("utf-8", errors="replace")
    s = str(x).strip()
    if len(s) >= 2 and s[0] == "'" and s[-1] == "'":
        return s[1:-1]
    return s


def _normalize_answer_for_prolog(value: AnswerValue) -> AnswerValue:
    """Map PyQt / locale quirks to atoms expected by inference_engine (yes/no/unknown, lowercase enums)."""
    if isinstance(value, bool):
        return "yes" if value else "no"
    if isinstance(value, int):
        return value
    s = _prolog_text(value).strip()
    low = s.lower()
    if low in ("yes", "true", "tak", "1", "on", "y"):
        return "yes"
    if low in ("no", "false", "nie", "0", "off", "n"):
        return "no"
    if low in ("unknown", "dont_know", "nie_wiem", "nie wiem", "?"):
        return "unknown"
    if re.fullmatch(r"[a-zA-Z0-9_]+", s):
        return s.lower()
    return s


def _log_progeo(msg: str) -> None:
    """Stderr + stdout: pliki typu `> log` bez 2>&1 i tak widzą problem."""
    line = f"[ProGeoLog] {msg}"
    print(line, flush=True, file=sys.stderr)
    print(line, flush=True, file=sys.stdout)


class ExpertSystemGUI(QMainWindow):
    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("ProGeoLog - Prototyp systemu ekspertowego")
        self.setMinimumWidth(960)
        self.setMinimumHeight(520)

        self.answers: Dict[str, AnswerValue] = {}
        self.questions: List[Question] = []
        self.questions_by_id: Dict[str, Question] = {}
        self.current_question: Question | None = None
        self.init_failed: bool = False
        self.dialog_finished: bool = False
        self.base_dir = Path(__file__).resolve().parent

        self.prolog = None
        self._init_ui()
        self._init_prolog()
        if self.init_failed:
            return
        self._load_questions()
        if self.init_failed:
            return
        self._reset_prolog_session()
        self._render_next_question()

    def _init_ui(self) -> None:
        central = QWidget()
        self.setCentralWidget(central)
        root = QHBoxLayout(central)

        dialog_col = QVBoxLayout()
        self.status_label = QLabel("Inicjalizacja...")
        self.question_label = QLabel("")
        self.question_label.setWordWrap(True)

        self.answer_container = QWidget()
        self.answer_layout = QVBoxLayout(self.answer_container)

        buttons = QHBoxLayout()
        self.reset_button = QPushButton("Reset")
        self.reset_button.setToolTip("Wyczyść odpowiedzi i rozpocznij dialog od początku")
        self.reset_button.clicked.connect(self.on_reset_clicked)
        self.next_button = QPushButton("Zatwierdź i dalej")
        self.next_button.clicked.connect(self.on_next_clicked)
        buttons.addWidget(self.reset_button)
        buttons.addWidget(self.next_button)

        dialog_col.addWidget(self.status_label)
        dialog_col.addWidget(self.question_label)
        dialog_col.addWidget(self.answer_container)
        dialog_col.addLayout(buttons)

        ranking_col = QVBoxLayout()
        self.ranking_title = QLabel("Top 10 krajów (pewność)")
        self.ranking_title.setWordWrap(True)
        self.ranking_list = QListWidget()
        self.ranking_list.setMinimumWidth(300)
        ranking_col.addWidget(self.ranking_title)
        ranking_col.addWidget(self.ranking_list)

        root.addLayout(dialog_col, stretch=3)
        root.addLayout(ranking_col, stretch=2)

        self.radio_group = QButtonGroup(self)
        self.radio_group.setExclusive(True)
        self.slider: QSlider | None = None

    def _prolog_assertz_clause(self, inner: str) -> None:
        """Assert one clause; prefer pyswip 0.3+ Prolog.assertz (reliable side effects)."""
        assert self.prolog is not None
        p = self.prolog
        if hasattr(p, "assertz"):
            p.assertz(inner)
            return
        rows = list(p.query(f"assertz(({inner}))"))
        if not rows:
            raise RuntimeError(f"assertz failed for: {inner}")

    def _prolog_retractall(self, inner: str) -> None:
        assert self.prolog is not None
        p = self.prolog
        if hasattr(p, "retractall"):
            p.retractall(inner)
            return
        rows = list(p.query(f"retractall(({inner}))"))
        if not rows:
            raise RuntimeError(f"retractall failed for: {inner}")

    def _init_prolog(self) -> None:
        if IMPORT_ERROR is not None:
            self._fatal(f"Nie można zaimportować pyswip: {IMPORT_ERROR}")
            return
        try:
            self.prolog = Prolog()
            # inference_engine must load before dialog_strategy (uses infer_scores/2).
            for fname in [
                "knowledge_base_template.pl",
                "inference_engine.pl",
                "dialog_strategy.pl",
                "gui_session.pl",
                "minimal_rules.pl",
            ]:
                full_path = (self.base_dir / fname).as_posix()
                self.prolog.consult(full_path)
        except Exception as exc:  # pragma: no cover - runtime integration
            self._fatal(f"Błąd inicjalizacji Prolog: {exc}")

    def _enum_values_for_feature(self, feature: str) -> List[str]:
        if not self.prolog or not re.fullmatch(r"^[a-z][a-z0-9_]*$", feature):
            return []
        try:
            rows = list(self.prolog.query(f"enum_wartosc({feature}, V)"))
            return [_prolog_text(r["V"]) for r in rows if r.get("V") is not None]
        except Exception:
            return []

    def _questions_from_prolog_rows(self, rows: List[Dict[str, Any]]) -> List[Question]:
        out: List[Question] = []
        for row in rows:
            feature = _prolog_text(row["Feature"])
            input_type = _prolog_text(row["InputType"])
            enum_values: Optional[List[str]] = None
            if input_type == "enum":
                enum_values = self._enum_values_for_feature(feature) or None
            out.append(
                Question(
                    qid=_prolog_text(row["Id"]),
                    feature=feature,
                    input_type=input_type,
                    context=_prolog_text(row["Context"]),
                    enum_values=enum_values,
                )
            )
        return out

    def _load_questions(self) -> None:
        if not self.prolog:
            return
        try:
            rows = list(self.prolog.query("pytanie(Id, Feature, InputType, Context)"))
        except Exception as exc:
            self._fatal(f"Nie udało się pobrać pytań z Prologa: {exc}")
            return
        self.questions = self._questions_from_prolog_rows(rows)
        self.questions_by_id = {q.qid: q for q in self.questions}
        if not self.questions:
            self._fatal(
                "Inicjalizacja zakończona, ale nie znaleziono pytań (pytanie/4). "
                "Sprawdź plik knowledge_base_template.pl."
            )
            return
        self.status_label.setText(
            f"Dialog kontekstowy | pytań w bazie: {len(self.questions)} | udzielono: 0"
        )
        self._refresh_ranking()

    def _refresh_ranking(self) -> None:
        self.ranking_list.clear()
        if not self.prolog or self.init_failed:
            self.ranking_list.addItem("Ranking niedostępny (Prolog)")
            return
        if not self.answers:
            self.ranking_list.addItem("Udziel pierwszej odpowiedzi, aby zobaczyć ranking.")
            return
        self._sync_prolog_session_from_answers()
        try:
            rows = list(self.prolog.query(f"{_SESSION_MOD}:gui_infer_scores(Country, Score)"))
        except Exception as exc:
            self.ranking_list.addItem(f"Błąd rankingu: {exc}")
            return
        ranked = self._sort_country_scores(rows)[:10]
        if not ranked:
            self.ranking_list.addItem("Brak wyników")
            return
        if ranked[0][1] < 0.001:
            self.ranking_list.addItem("Brak wystarczających dowodów — udziel więcej odpowiedzi.")
            return
        for rank, (country_atom, score) in enumerate(ranked, start=1):
            label = self._country_label(country_atom)
            self.ranking_list.addItem(f"{rank}. {label}  —  {score:.3f}")

    def _sort_country_scores(self, rows: List[Dict[str, Any]]) -> List[Tuple[str, float]]:
        pairs: List[Tuple[str, float]] = []
        for row in rows:
            country = _prolog_text(row["Country"])
            score = float(str(row["Score"]).replace(",", "."))
            pairs.append((country, score))
        pairs.sort(key=lambda item: item[1], reverse=True)
        return pairs

    def _current_ranked_scores(self) -> List[Tuple[str, float]]:
        if not self.prolog or self.init_failed or not self.answers:
            return []
        self._sync_prolog_session_from_answers()
        try:
            rows = list(self.prolog.query(f"{_SESSION_MOD}:gui_infer_scores(Country, Score)"))
        except Exception:
            return []
        return self._sort_country_scores(rows)

    def _winner_above_threshold(
        self, threshold: float = CONFIDENCE_WIN_THRESHOLD
    ) -> Optional[Tuple[str, float]]:
        ranked = self._current_ranked_scores()
        if not ranked:
            return None
        country, score = ranked[0]
        if score > threshold:
            return country, score
        return None

    def _finish_dialog_resolved(self, country_atom: str, score: float) -> None:
        self.dialog_finished = True
        label = self._country_label(country_atom)
        self.question_label.setText(
            f"Rozstrzygnięto: {label} (pewność {score:.3f}). "
            f"Dialog zakończony — próg to pewność powyżej {CONFIDENCE_WIN_THRESHOLD:.1f}."
        )
        self._clear_answer_widgets()
        self.current_question = None
        self.next_button.setEnabled(False)
        self.ranking_title.setText("Wynik końcowy")
        self._update_status_line()
        self._refresh_ranking()

    def _finish_dialog_unresolved(self) -> None:
        self.dialog_finished = True
        ranked = self._current_ranked_scores()
        hint = ""
        if ranked:
            top_label = self._country_label(ranked[0][0])
            hint = f" Najwyższa pewność: {top_label} ({ranked[0][1]:.3f})."
        self.question_label.setText(
            "Brak rozstrzygnięcia — żaden kraj nie osiągnął pewności powyżej "
            f"{CONFIDENCE_WIN_THRESHOLD:.1f}. Zadano wszystkie dostępne pytania."
            f"{hint} Zobacz ranking po prawej."
        )
        self._clear_answer_widgets()
        self.current_question = None
        self.next_button.setEnabled(False)
        self._update_status_line()
        self._refresh_ranking()

    def _try_finish_after_answer(self) -> bool:
        """Zwraca True, jeśli dialog został zakończony (wygrana lub brak pytań)."""
        winner = self._winner_above_threshold()
        if winner is not None:
            self._finish_dialog_resolved(winner[0], winner[1])
            return True
        return False

    def _update_status_line(self) -> None:
        n = len(self.answers)
        total = len(self.questions)
        self.status_label.setText(
            f"Dialog kontekstowy | pytań w bazie: {total} | udzielono: {n}"
        )

    def _sync_prolog_session_from_answers(self) -> None:
        """Push self.answers into Prolog dynamic facts (assertz/retractall API for pyswip 0.3+)."""
        if not self.prolog:
            return
        m = _SESSION_MOD
        written = 0
        skipped: list[str] = []
        try:
            self._prolog_retractall(f"{m}:gui_answer(_,_)")
            for qid, value in self.answers.items():
                q = _prolog_text(qid)
                if not _QID_RE.match(q):
                    skipped.append(f"qid:{q!r}")
                    continue
                if isinstance(value, int):
                    self._prolog_assertz_clause(f"{m}:gui_answer({q}, {int(value)})")
                    written += 1
                    continue
                raw = _unwrap_qvariant(value)
                if isinstance(raw, int):
                    self._prolog_assertz_clause(f"{m}:gui_answer({q}, {raw})")
                    written += 1
                    continue
                v = _normalize_answer_for_prolog(_prolog_text(raw))
                if isinstance(v, int):
                    self._prolog_assertz_clause(f"{m}:gui_answer({q}, {v})")
                    written += 1
                    continue
                vs = str(v)
                if _ATOM_RE.match(vs):
                    self._prolog_assertz_clause(f"{m}:gui_answer({q}, {vs})")
                    written += 1
                else:
                    esc = vs.replace("\\", "\\\\").replace("'", "''")
                    self._prolog_assertz_clause(f"{m}:gui_answer({q}, '{esc}')")
                    written += 1
            if len(self.answers) > 0 and written != len(self.answers):
                _log_progeo(
                    f"sync: zapisano {written} z {len(self.answers)} odpowiedzi. "
                    f"Pominięte: {skipped or 'brak'}"
                )
        except Exception as exc:
            _log_progeo(f"Błąd synchronizacji: {exc}")
            traceback.print_exc(file=sys.stderr)
            traceback.print_exc(file=sys.stdout)

    def _next_contextual_qid(self) -> Optional[str]:
        if not self.prolog:
            return None
        self._sync_prolog_session_from_answers()
        query = f"{_SESSION_MOD}:gui_next_q(Qid)"
        try:
            rows = list(self.prolog.query(query))
        except Exception as exc:
            _log_progeo(f"gui_next_q: {exc}")
            traceback.print_exc(file=sys.stderr)
            traceback.print_exc(file=sys.stdout)
            return None
        if not rows:
            return None
        return _prolog_text(rows[0]["Qid"])

    def _render_next_question(self) -> None:
        if self.dialog_finished:
            return

        if not self.questions:
            self.question_label.setText("Brak pytań w bazie wiedzy.")
            self.next_button.setEnabled(False)
            return

        if self.answers and self._try_finish_after_answer():
            return

        if len(self.answers) >= len(self.questions):
            self._finish_dialog_unresolved()
            return

        next_qid = self._next_contextual_qid()
        if next_qid is None:
            self._finish_dialog_unresolved()
            return

        q = self.questions_by_id.get(next_qid)
        if q is None:
            self._fatal(
                f"Strategia dialogu zwróciła nieznane pytanie: {next_qid!r}. "
                "Sprawdź spójność identyfikatorów z pytanie/4."
            )
            return

        self.current_question = q
        self.question_label.setText(
            f"Pytanie ({q.context}): Jak oceniasz cechę `{q.feature}`?"
        )
        self._clear_answer_widgets()
        self._build_answer_widgets(q)
        self.next_button.setEnabled(True)
        self._update_status_line()
        self._refresh_ranking()

    def _clear_answer_widgets(self) -> None:
        while self.answer_layout.count():
            item = self.answer_layout.takeAt(0)
            widget = item.widget()
            if widget is not None:
                widget.deleteLater()
        for btn in self.radio_group.buttons():
            self.radio_group.removeButton(btn)
        self.slider = None

    def _build_answer_widgets(self, question: Question) -> None:
        if question.input_type == "radio":
            for text, value in [("Tak", "yes"), ("Nie", "no"), ("Nie wiem", "unknown")]:
                rb = QRadioButton(text)
                rb.setProperty("value", value)
                self.radio_group.addButton(rb)
                self.answer_layout.addWidget(rb)
        elif question.input_type == "slider":
            slider = QSlider()
            slider.setOrientation(1)  # Horizontal
            slider.setMinimum(0)
            slider.setMaximum(100)
            slider.setValue(50)
            label = QLabel("Wartość [0..100]: 50")
            slider.valueChanged.connect(lambda v: label.setText(f"Wartość [0..100]: {v}"))
            self.answer_layout.addWidget(label)
            self.answer_layout.addWidget(slider)
            self.slider = slider
            rb_unknown = QRadioButton("Nie wiem")
            rb_unknown.setProperty("value", "unknown")
            rb_unknown.setProperty("slider_unknown", True)
            self.radio_group.addButton(rb_unknown)
            self.answer_layout.addWidget(rb_unknown)
        elif question.input_type == "enum":
            opts = question.enum_values or []
            if not opts:
                _log_progeo(f"Brak enum_wartosc dla cechy {question.feature!r} — używam A/B/C.")
                for text, value in [
                    ("Wartość A", "a"),
                    ("Wartość B", "b"),
                    ("Wartość C", "c"),
                ]:
                    rb = QRadioButton(text)
                    rb.setProperty("value", value)
                    self.radio_group.addButton(rb)
                    self.answer_layout.addWidget(rb)
                return
            for atom in opts:
                if atom == "nie_wiem":
                    label = "Nie wiem"
                else:
                    label = atom.replace("_", " ")
                rb = QRadioButton(label)
                rb.setProperty("value", atom)
                self.radio_group.addButton(rb)
                self.answer_layout.addWidget(rb)
        else:
            for text, value in [
                ("Wartość A", "a"),
                ("Wartość B", "b"),
                ("Wartość C", "c"),
            ]:
                rb = QRadioButton(text)
                rb.setProperty("value", value)
                self.radio_group.addButton(rb)
                self.answer_layout.addWidget(rb)

    def _read_current_answer(self) -> AnswerValue | None:
        if not self.current_question:
            return None
        checked = self.radio_group.checkedButton()
        if checked is not None and checked.property("slider_unknown"):
            return "unknown"
        if self.current_question.input_type == "slider" and self.slider is not None:
            return int(self.slider.value())
        if checked is None:
            return None
        raw = checked.property("value")
        v = _unwrap_qvariant(raw)
        if isinstance(v, bool):
            return _normalize_answer_for_prolog(v)
        if isinstance(v, str):
            return _normalize_answer_for_prolog(v) if v else v
        if isinstance(v, (int, float)) and not isinstance(v, bool):
            return int(v)
        if v is None:
            return None
        return _normalize_answer_for_prolog(str(v))

    def on_next_clicked(self) -> None:
        if self.dialog_finished or not self.current_question:
            return
        answer = self._read_current_answer()
        if answer is None:
            QMessageBox.warning(self, "Brak odpowiedzi", "Wybierz odpowiedź przed przejściem dalej.")
            return
        self.answers[self.current_question.qid] = answer
        self._update_status_line()
        self._refresh_ranking()
        if self._try_finish_after_answer():
            return
        self._render_next_question()

    def _country_label(self, country_atom: str) -> str:
        if not self.prolog:
            return country_atom
        try:
            rows = list(self.prolog.query(f"kraj_ui_label({country_atom}, Label)"))
            if rows:
                return str(rows[0]["Label"])
        except Exception:
            pass
        return country_atom

    def _reset_prolog_session(self) -> None:
        if not self.prolog:
            return
        try:
            list(self.prolog.query(f"{_SESSION_MOD}:gui_reset"))
        except Exception as exc:
            _log_progeo(f"gui_reset: {exc}")
            self._prolog_retractall(f"{_SESSION_MOD}:gui_answer(_, _)")

    def _reset_dialog(self) -> None:
        """Przywraca stan początkowy GUI i dynamicznej sesji Prolog (gui_answer/2)."""
        self.answers.clear()
        self.dialog_finished = False
        self.current_question = None
        self._reset_prolog_session()
        self.ranking_title.setText("Top 10 krajów (pewność)")
        self.next_button.setEnabled(True)
        self._clear_answer_widgets()
        self._update_status_line()
        self.ranking_list.clear()
        self.ranking_list.addItem("Udziel pierwszej odpowiedzi, aby zobaczyć ranking.")
        if not self.init_failed and self.questions:
            self._render_next_question()
        else:
            self.question_label.setText("")

    def on_reset_clicked(self) -> None:
        if self.init_failed:
            return
        if self.answers and not self.dialog_finished:
            reply = QMessageBox.question(
                self,
                "Reset dialogu",
                "Czy na pewno chcesz wyczyścić odpowiedzi i rozpocząć od nowa?",
                QMessageBox.Yes | QMessageBox.No,
                QMessageBox.No,
            )
            if reply != QMessageBox.Yes:
                return
        self._reset_dialog()

    def _fatal(self, message: str) -> None:
        self.init_failed = True
        self.status_label.setText("Błąd inicjalizacji")
        self.question_label.setText(message)
        self.next_button.setEnabled(False)
        self.reset_button.setEnabled(False)
        self.ranking_list.clear()
        self.ranking_list.addItem("Błąd inicjalizacji")


def main() -> None:
    app = QApplication(sys.argv)
    window = ExpertSystemGUI()
    window.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
