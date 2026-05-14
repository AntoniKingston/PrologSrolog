% Bridge between PyQt/pyswip and dialog/inference: avoids embedding Prolog
% list-of-pairs in query strings (parsers often mishandle those terms).
:- module(gui_session, [
    gui_reset/0,
    gui_add/2,
    gui_answer_count/1,
    gui_next_q/1,
    gui_best_country/2
]).

:- use_module(dialog_strategy, [next_contextual_question/2]).
:- use_module(inference_engine, [best_country/2]).

:- dynamic gui_answer/2.

gui_reset :-
    retractall(gui_answer(_, _)).

gui_add(Q, V) :-
    assertz(gui_answer(Q, V)).

gui_answer_count(N) :-
    findall(_, gui_answer(_, _), L),
    length(L, N).

gui_answer_list(Answers) :-
    findall(Q-V, gui_answer(Q, V), Answers).

gui_next_q(Qid) :-
    gui_answer_list(Answers),
    next_contextual_question(Answers, Qid).

gui_best_country(Country, Score) :-
    gui_answer_list(Answers),
    best_country(Answers, Country-Score).
