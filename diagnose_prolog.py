#!/usr/bin/env python3
"""
Diagnostyka mostu Python ↔ SWI-Prolog (bez PyQt).

Gdzie uruchomić: w katalogu głównym repozytorium PrologSrolog (tam gdzie jest gui_app.py).

    cd /ścieżka/do/PrologSrolog
    python3 diagnose_prolog.py

Co wkleić do czatu: CAŁY wynik z terminala (od pierwszej linii do ostatniej),
nie pojedynczą linię — wtedy widać wersję pyswip, assertz, licznik faktów i wynik inferencji.

Log z gui_app.py (żeby trafiły też ewentualne stderr — użyj 2>&1):

    python3 gui_app.py 2>&1 | tee progeo_log.txt
"""
from __future__ import annotations

import sys
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parent
    print("=== ProGeoLog diagnose_prolog.py ===")
    print(f"Katalog projektu: {root}")
    print(f"Python: {sys.executable}")
    print()

    try:
        from pyswip import Prolog
    except ImportError as e:
        print("BŁĄD: nie da się zaimportować pyswip:", e)
        print("Zainstaluj w TYM SAMYM środowisku co GUI: pip install pyswip")
        return 1

    print("pyswip:", getattr(Prolog, "__module__", "?"))
    print("Prolog.assertz:", hasattr(Prolog, "assertz"), "| Prolog.retractall:", hasattr(Prolog, "retractall"))
    print()

    p = Prolog()
    files = [
        "knowledge_base_template.pl",
        "inference_engine.pl",
        "dialog_strategy.pl",
        "gui_session.pl",
        "minimal_rules.pl",
    ]
    for fname in files:
        path = (root / fname).as_posix()
        print("consult:", path)
        try:
            p.consult(path)
        except Exception as exc:
            print("  BŁĄD consult:", exc)
            return 1
    print("consult: OK")
    print()

    m = "gui_session"

    def retract() -> None:
        inner = f"{m}:gui_answer(_,_)"
        if hasattr(p, "retractall"):
            p.retractall(inner)
        else:
            list(p.query(f"retractall(({inner}))"))

    def fact(q: str, v: str) -> None:
        inner = f"{m}:gui_answer({q}, {v})"
        if hasattr(p, "assertz"):
            p.assertz(inner)
        else:
            list(p.query(f"assertz(({inner}))"))

    retract()
    fact("q_ruch_lewostronny", "no")
    fact("q_znak_speed_limit_usa", "yes")
    fact("q_tablica_dluga_eu", "no")

    rows = list(p.query(f"{m}:gui_answer_count(N)"))
    print("Oczekiwane: 3 fakty gui_answer w Prologu.")
    print("gui_answer_count:", rows)
    if not rows:
        print("BŁĄD: brak wyniku gui_answer_count — fakty nie trafiły do Prologa (assertz/query).")
        return 1

    n_raw = rows[0].get("N")
    print("  N (surowe):", repr(n_raw), type(n_raw))
    try:
        n = int(float(str(n_raw).replace(",", ".")))
    except (TypeError, ValueError):
        n = -1
    if n != 3:
        print(f"BŁĄD: oczekiwano N=3, jest N={n}")
        return 1
    print("gui_answer_count: OK (N=3)")
    print()

    rows = list(p.query(f"{m}:gui_best_country(Country, Score)"))
    print("gui_best_country (jak przycisk „Pokaż wynik”):", rows)
    if rows:
        c, s = rows[0].get("Country"), rows[0].get("Score")
        print("  Country:", repr(c), "| Score:", repr(s))
        try:
            sf = float(str(s).replace(",", "."))
            if sf <= 0.0:
                print("UWAGA: Score=0 — sprawdź inference_engine (premise yes/no vs tak/nie).")
        except (TypeError, ValueError):
            pass
    print()

    rows = list(p.query(f"{m}:gui_next_q(Qid)"))
    print("gui_next_q (kolejne pytanie przy tych odpowiedziach):", rows)
    if rows:
        print("  Qid:", repr(rows[0].get("Qid")))

    print()
    print("=== Koniec diagnostyki ===")
    print("Skopiuj WSZYSTKO od „=== ProGeoLog” powyżej i wklej do czatu.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
