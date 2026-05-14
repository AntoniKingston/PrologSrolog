import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Union

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


class ExpertSystemGUI(QMainWindow):
    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("ProGeoLog - Prototyp systemu ekspertowego")
        self.setMinimumWidth(700)

        self.answers: Dict[str, AnswerValue] = {}
        self.questions: List[Question] = []
        self.questions_by_id: Dict[str, Question] = {}
        self.current_question: Question | None = None
        self.init_failed: bool = False
        self.base_dir = Path(__file__).resolve().parent

        self.prolog = None
        self._init_ui()
        self._init_prolog()
        if self.init_failed:
            return
        self._load_questions()
        if self.init_failed:
            return
        self._render_next_question()

    def _init_ui(self) -> None:
        central = QWidget()
        self.setCentralWidget(central)
        root = QVBoxLayout(central)

        self.status_label = QLabel("Inicjalizacja...")
        self.question_label = QLabel("")
        self.question_label.setWordWrap(True)

        self.answer_container = QWidget()
        self.answer_layout = QVBoxLayout(self.answer_container)

        buttons = QHBoxLayout()
        self.next_button = QPushButton("Zatwierdź i dalej")
        self.next_button.clicked.connect(self.on_next_clicked)
        self.finish_button = QPushButton("Pokaż wynik")
        self.finish_button.clicked.connect(self.on_finish_clicked)
        buttons.addWidget(self.next_button)
        buttons.addWidget(self.finish_button)

        root.addWidget(self.status_label)
        root.addWidget(self.question_label)
        root.addWidget(self.answer_container)
        root.addLayout(buttons)

        self.radio_group = QButtonGroup(self)
        self.radio_group.setExclusive(True)
        self.slider: QSlider | None = None

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
                "minimal_rules.pl",
            ]:
                full_path = (self.base_dir / fname).as_posix()
                self.prolog.consult(full_path)
        except Exception as exc:  # pragma: no cover - runtime integration
            self._fatal(f"Błąd inicjalizacji Prolog: {exc}")

    def _load_questions(self) -> None:
        if not self.prolog:
            return
        try:
            rows = list(self.prolog.query("pytanie(Id, Feature, InputType, Context)"))
        except Exception as exc:
            self._fatal(f"Nie udało się pobrać pytań z Prologa: {exc}")
            return
        self.questions = [
            Question(
                qid=str(row["Id"]),
                feature=str(row["Feature"]),
                input_type=str(row["InputType"]),
                context=str(row["Context"]),
            )
            for row in rows
        ]
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

    def _update_status_line(self) -> None:
        n = len(self.answers)
        total = len(self.questions)
        self.status_label.setText(
            f"Dialog kontekstowy | pytań w bazie: {total} | udzielono: {n}"
        )

    def _next_contextual_qid(self) -> Optional[str]:
        if not self.prolog:
            return None
        prolog_answers = self._answers_to_prolog_list()
        query = f"next_contextual_question({prolog_answers}, Qid)"
        try:
            rows = list(self.prolog.query(query))
        except Exception:
            return None
        if not rows:
            return None
        return str(rows[0]["Qid"])

    def _render_next_question(self) -> None:
        if not self.questions:
            self.question_label.setText("Brak pytań w bazie wiedzy.")
            self.next_button.setEnabled(False)
            return

        if len(self.answers) >= len(self.questions):
            self.question_label.setText(
                "Wszystkie pytania wypełnione. Możesz pokazać wynik."
            )
            self._clear_answer_widgets()
            self.current_question = None
            self.next_button.setEnabled(False)
            self._update_status_line()
            return

        next_qid = self._next_contextual_qid()
        if next_qid is None:
            self.question_label.setText(
                "Brak kolejnego pytania (wszystkie cechy już ocenione lub błąd strategii). "
                "Możesz pokazać wynik na podstawie dotychczasowych odpowiedzi."
            )
            self._clear_answer_widgets()
            self.current_question = None
            self.next_button.setEnabled(False)
            self._update_status_line()
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
        if self.current_question.input_type == "slider" and self.slider is not None:
            return int(self.slider.value())
        checked = self.radio_group.checkedButton()
        if checked is None:
            return None
        return str(checked.property("value"))

    def on_next_clicked(self) -> None:
        if not self.current_question:
            return
        answer = self._read_current_answer()
        if answer is None:
            QMessageBox.warning(self, "Brak odpowiedzi", "Wybierz odpowiedź przed przejściem dalej.")
            return
        self.answers[self.current_question.qid] = answer
        self._update_status_line()
        self._render_next_question()

    def on_finish_clicked(self) -> None:
        if not self.prolog:
            return
        prolog_answers = self._answers_to_prolog_list()
        query = f"best_country({prolog_answers}, Country-Score)"
        try:
            result = list(self.prolog.query(query))
        except Exception as exc:
            QMessageBox.critical(self, "Błąd Prolog", str(exc))
            return
        if not result:
            QMessageBox.information(self, "Wynik", "Nie udało się wyznaczyć hipotezy.")
            return
        country_atom = str(result[0]["Country"])
        score = float(result[0]["Score"])
        label = self._country_label(country_atom)
        QMessageBox.information(
            self,
            "Wynik",
            f"Najlepsza hipoteza: {label} ({country_atom})\nPewność: {score:.3f}",
        )

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

    def _answers_to_prolog_list(self) -> str:
        # Builds list: [q_ruch-yes, q_gory-70]
        parts: List[str] = []
        for qid, value in self.answers.items():
            if isinstance(value, int):
                parts.append(f"{qid}-{value}")
            else:
                parts.append(f"{qid}-{value}")
        return "[" + ", ".join(parts) + "]"

    def _fatal(self, message: str) -> None:
        self.init_failed = True
        self.status_label.setText("Błąd inicjalizacji")
        self.question_label.setText(message)
        self.next_button.setEnabled(False)
        self.finish_button.setEnabled(False)


def main() -> None:
    app = QApplication(sys.argv)
    window = ExpertSystemGUI()
    window.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
