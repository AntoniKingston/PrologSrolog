% Bridge between PyQt/pyswip and dialog/inference: avoids embedding Prolog
% list-of-pairs in query strings (parsers often mishandle those terms).
:- module(gui_session, [
    gui_reset/0,
    gui_add/2,
    gui_answer_count/1,
    gui_next_q/1,
    gui_best_country/2,
    gui_infer_scores/2,
    gui_dialog_status/3
]).

:- use_module(dialog_strategy, [
    next_contextual_question/2,
    active_hypotheses/2,
    unresolved_hypothesis_pairs/2
]).
:- use_module(inference_engine, [best_country/2, infer_scores/2]).

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
    next_contextual_question(Answers, Qid),
    !.

gui_best_country(Country, Score) :-
    gui_answer_list(Answers),
    best_country(Answers, Country-Score).

gui_infer_scores(Country, Score) :-
    gui_answer_list(Answers),
    infer_scores(Answers, Scores),
    member(Country-Score, Scores).

% Liczba aktywnych hipotez i nierozróżnionych par (do paska statusu GUI).
gui_dialog_status(NumHypotheses, NumPairs, TopPair) :-
    gui_answer_list(Answers),
    active_hypotheses(Answers, Hypotheses),
    length(Hypotheses, NumHypotheses),
    unresolved_hypothesis_pairs(Answers, Pairs),
    length(Pairs, NumPairs),
    ( Pairs = [A-B | _] ->
        TopPair = pair(A, B)
    ; TopPair = none
    ),
    !.
