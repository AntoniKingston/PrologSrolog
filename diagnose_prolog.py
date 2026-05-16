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
    fact("q_strona_ruchu", "prawostronny")
    fact("q_ksztalt_znaku_ograniczenia", "prostokatny")
    fact("q_kolor_znaku_ograniczenia", "z_czerwona_obwodka")

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
    print("gui_best_country / gui_wynik_koncowy (konspekt wynik_koncowy/2):", rows)
    if rows:
        c, s = rows[0].get("Country"), rows[0].get("Score")
        print("  Country:", repr(c), "| Score:", repr(s))
        try:
            sf = float(str(s).replace(",", "."))
            if sf <= 0.0:
                print("UWAGA: Score=0 — sprawdź inference_engine (premise yes/no vs tak/nie).")
        except (TypeError, ValueError):
            pass

    hip = list(p.query(f"{m}:gui_hipoteza(Country, Score)"))
    print(f"gui_hipoteza (dynamiczne hipoteza/2): {len(hip)} krajów")
    wk = list(p.query(f"inference_engine:wynik_koncowy(K, P)"))
    print("inference_engine:wynik_koncowy/2 po inferencji:", wk)
    if rows and wk:
        c0 = str(rows[0].get("Country"))
        k0 = str(wk[0].get("K"))
        if c0 != k0:
            print("UWAGA: gui_best_country i wynik_koncowy/2 różnią się co do kraju.")
    print()

    rows = list(p.query(f"{m}:gui_next_q(Qid)", maxresult=1))
    print("gui_next_q (kolejne pytanie przy tych odpowiedziach):", rows)
    if rows:
        print("  Qid:", repr(rows[0].get("Qid")))
    extra = list(p.query(f"{m}:gui_next_q(Qid)", maxresult=2))
    if len(extra) > 1:
        print(f"  UWAGA: gui_next_q ma >1 rozwiązanie ({len(extra)}) — sprawdź determinizm dialog_strategy.")

    print()
    print("=== Reguły minimalne (minimal_rules.pl) ===")
    try:
        core_rows = list(p.query("minimal_rules:core_attributes(C)"))
        reduct_rows = list(p.query("minimal_rules:find_reduct(R)"))
        attr_rows = list(p.query("minimal_rules:all_condition_attributes(A)"))
        if attr_rows:
            attrs = attr_rows[0].get("A")
            print("  atrybuty warunkowe:", len(attrs) if isinstance(attrs, list) else attrs)
        if core_rows:
            print("  rdzeń (core):", core_rows[0].get("C"))
        if reduct_rows:
            print("  redukt:", reduct_rows[0].get("R"))
        mr = list(
            p.query(
                "minimal_rules:minimal_rules_for_country(usa, Rules), length(Rules, N)"
            )
        )
        if mr:
            print("  reguły minimalne (usa):", mr[0].get("N"))
    except Exception as exc:
        print("  BŁĄD minimal_rules:", exc)
    print()
    print("=== Koniec diagnostyki ===")
    print("Skopiuj WSZYSTKO od „=== ProGeoLog” powyżej i wklej do czatu.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
