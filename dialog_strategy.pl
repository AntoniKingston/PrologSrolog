:- module(dialog_strategy, [
    next_question/3,
    unanswered_questions/2,
    candidate_countries/2,
    active_hypotheses/2,
    unresolved_hypothesis_pairs/2,
    question_separatory_power/3,
    next_contextual_question/2
]).

:- use_module(library(lists)).
:- use_module('knowledge_base_template.pl').
:- use_module(inference_engine, [infer_scores/2]).

% Progi dialogu kontekstowego (zgodnie z konspektem: pary hipotez + moc separacyjna).
max_unresolved_pairs(12).
max_simulation_pairs(6).
max_simulation_questions(3).
score_unresolved_absolute_margin(0.10).
score_unresolved_relative_margin(0.22).
min_active_hypothesis_score(0.02).

% --- Pytania bez odpowiedzi ---
unanswered_questions(KnownAnswers, QuestionIds) :-
    findall(
        Id,
        (pytanie(Id, _Feature, _InputType, _Context), \+ memberchk(Id-_, KnownAnswers)),
        QuestionIds
    ).

% --- Aktywne hipotezy (kraje nadal konkurencyjne wg wyniku inferencji) ---
active_hypotheses(Answers, Hypotheses) :-
    candidate_countries(Answers, Hypotheses).

candidate_countries(Answers, Candidates) :-
    infer_scores(Answers, Scores),
    sort_scores_desc(Scores, Sorted),
    hypotheses_from_scores(Sorted, Candidates).

hypotheses_from_scores(Sorted, Candidates) :-
    first_score(Sorted, Max),
    min_active_hypothesis_score(MinActive),
    ( Max > MinActive ->
        score_cluster_hypotheses(Sorted, Max, Candidates)
    ; all_countries_hypotheses(Candidates)
    ).

score_cluster_hypotheses(Sorted, Max, Candidates) :-
    score_unresolved_absolute_margin(AbsM),
    score_unresolved_relative_margin(RelM),
    Margin is max(AbsM, Max * RelM),
    Threshold is Max - Margin,
    findall(C, (member(C-S, Sorted), S >= Threshold), Cs),
    ( Cs = [] ->
        Sorted = [C1-_, C2-_|_],
        Candidates = [C1, C2]
    ; Cs = [Only] ->
        Sorted = [Only-_, Second-_|_],
        Candidates = [Only, Second]
    ; Candidates = Cs
    ).

all_countries_hypotheses(Candidates) :-
    structural_competitor_pairs(Pairs),
    ( Pairs = [] ->
        findall(C, kraj(C), Candidates)
    ;
        findall(C, (member(A-B, Pairs), (C = A ; C = B)), Cs),
        sort(Cs, Candidates)
    ).

% --- Nierozróżnione pary hipotez (A,B): nadal konkurencyjne, blisko w rankingu ---
unresolved_hypothesis_pairs(Answers, Pairs) :-
    active_hypotheses(Answers, Hypotheses),
    length(Hypotheses, N),
    ( N < 2 ->
        Pairs = []
    ; raw_unresolved_pairs(Answers, Hypotheses, Raw),
      cap_unresolved_pairs(Raw, Answers, Pairs)
    ).

raw_unresolved_pairs(Answers, Hypotheses, Pairs) :-
    infer_scores(Answers, Scores),
    max_list_scores(Scores, Max),
    min_active_hypothesis_score(MinActive),
    ( Max > MinActive ->
        score_based_pairs(Hypotheses, Scores, Max, Pairs0),
        ( Pairs0 = [] ->
            top_ambiguous_pair(Hypotheses, Scores, Pairs)
        ; Pairs = Pairs0
        )
    ; structural_competitor_pairs(Pairs)
    ).

score_based_pairs(Hypotheses, Scores, Max, Pairs) :-
    score_unresolved_absolute_margin(AbsM),
    score_unresolved_relative_margin(RelM),
    Margin is max(AbsM, Max * RelM),
    findall(
        A-B,
        ( member(A, Hypotheses),
          member(B, Hypotheses),
          A @< B,
          member(A-Sa, Scores),
          member(B-Sb, Scores),
          abs(Sa - Sb) =< Margin
        ),
        Pairs
    ).

top_ambiguous_pair(Hypotheses, Scores, [A-B]) :-
    findall(Gap-A-B,
        ( member(A, Hypotheses),
          member(B, Hypotheses),
          A @< B,
          member(A-Sa, Scores),
          member(B-Sb, Scores),
          Gap is abs(Sa - Sb)
        ),
        Keyed),
    Keyed \= [],
    keysort(Keyed, Asc),
    last(Asc, _-A-B).

% Przy braku dowodów: pary krajów z tą samą listą przesłanek w regule CF (konkurencja wiedzy).
structural_competitor_pairs(Pairs) :-
    findall(
        A-B,
        ( regula_cf(_Rid, A, Premises, Weight, _Priority),
          Weight >= 0.35,
          regula_cf(_, B, Premises, _, _),
          A @< B
        ),
        Raw
    ),
    sort(Raw, Pairs).

cap_unresolved_pairs(Raw, Answers, Pairs) :-
    max_unresolved_pairs(MaxN),
    length(Raw, L),
    ( L =< MaxN ->
        Pairs = Raw
    ; rank_pairs_by_ambiguity(Raw, Answers, Ranked),
      take_pairs(Ranked, MaxN, Pairs)
    ).

rank_pairs_by_ambiguity(Pairs, Answers, Ranked) :-
    infer_scores(Answers, Scores),
    findall(Key-A-B,
        ( member(A-B, Pairs),
          pair_ambiguity_key(A-B, Scores, Key)
        ),
        Keyed),
    keysort(Keyed, Asc),
    reverse(Asc, Ranked).

pair_ambiguity_key(A-B, Scores, Key) :-
    ( member(A-Sa, Scores), member(B-Sb, Scores) ->
        Key is abs(Sa - Sb)
    ; shared_premise_weight(A, B, Key)
    ).

shared_premise_weight(A, B, NegWeight) :-
    regula_cf(_, A, Premises, W, _),
    regula_cf(_, B, Premises, _, _),
    NegWeight is -W.

take_pairs([], _, []).
take_pairs(_, 0, []) :- !.
take_pairs([_-A-B | Rest], N, [A-B | Out]) :-
    N > 0,
    N1 is N - 1,
    take_pairs(Rest, N1, Out).

max_list_scores(Scores, Max) :-
    findall(S, member(_-S, Scores), Rs),
    ( Rs = [] -> Max = 0.0 ; max_list(Rs, Max) ).

% --- Moc separacyjna pytania względem par hipotez ---
% Faza 1: szybka ocena z reguł CF; faza 2: symulacja infer_scores dla kandydatów z fazy 1.
question_separatory_power(Qid, Answers, Power) :-
    pytanie(Qid, Feature, _InputType, _Context),
    unresolved_hypothesis_pairs(Answers, Pairs),
    ( Pairs = [] ->
        Power = 0.0
    ; pairs_relevant_to_feature(Pairs, Feature),
      rule_based_question_power(Qid, Pairs, RulePower),
      ( RulePower > 0.001 ->
          simulation_question_power(Qid, Answers, Pairs, SimPower),
          Power is max(RulePower, SimPower) + Qid / 100000.0
      ; Power is RulePower + Qid / 100000.0
      )
    ).

rule_based_question_power(Qid, Pairs, Power) :-
    pytanie(Qid, Feature, _, _),
    sum_rule_separations(Pairs, Feature, Sum),
    atom_length(Qid, Tie),
    Power is Sum + Tie / 100000.0.

sum_rule_separations([], _, 0.0).
sum_rule_separations([A-B | Rest], Feature, Total) :-
    rule_based_pair_separation(A, B, Feature, Sep),
    sum_rule_separations(Rest, Feature, RestSum),
    Total is Sep + RestSum.

simulation_question_power(Qid, Answers, Pairs, Power) :-
    pytanie(Qid, Feature, _, _),
    pairs_for_feature(Pairs, Feature, Relevant),
    cap_pairs_for_simulation(Relevant, SimPairs),
    sum_pair_separations(Answers, Qid, SimPairs, Power).

pairs_for_feature(Pairs, Feature, Relevant) :-
    findall(
        A-B,
        ( member(A-B, Pairs),
          ( country_uses_feature_in_rules(A, Feature)
          ; country_uses_feature_in_rules(B, Feature)
          )
        ),
        Relevant
    ).

cap_pairs_for_simulation(Pairs, Pairs) :-
    length(Pairs, L),
    max_simulation_pairs(Max),
    L =< Max,
    !.
cap_pairs_for_simulation(Pairs, Capped) :-
    max_simulation_pairs(Max),
    take_pairs_from_list(Pairs, Max, Capped).

take_pairs_from_list([], _, []).
take_pairs_from_list(_, 0, []) :- !.
take_pairs_from_list([H | T], N, [H | Out]) :-
    N > 0,
    N1 is N - 1,
    take_pairs_from_list(T, N1, Out).

pairs_relevant_to_feature(Pairs, Feature) :-
    member(A-B, Pairs),
    ( country_uses_feature_in_rules(A, Feature)
    ; country_uses_feature_in_rules(B, Feature)
    ),
    !.

country_uses_feature_in_rules(Country, Feature) :-
    regula_cf(_Rid, Country, Premises, _, _),
    premise_mentions_feature(Premises, Feature),
    !.
country_uses_feature_in_rules(Country, Feature) :-
    regula_fuzzy(_Rid, Country, Feature, _, _),
    !.

sum_pair_separations(_, _, [], 0.0).
sum_pair_separations(Answers, Qid, [A-B | Rest], Total) :-
    pair_question_separation(Answers, Qid, A, B, Sep),
    sum_pair_separations(Answers, Qid, Rest, RestSum),
    Total is Sep + RestSum.

pair_question_separation(Answers, Qid, C1, C2, Separation) :-
    pytanie(Qid, Feature, InputType, _),
    possible_answer_values(InputType, Feature, Values),
    findall(
        Delta,
        ( member(Value, Values),
          hypothetical_answers(Answers, Qid, Value, Hyp),
          infer_scores(Hyp, Scores),
          member(C1-S1, Scores),
          member(C2-S2, Scores),
          Delta is abs(S1 - S2)
        ),
        Deltas
    ),
    ( Deltas = [] ->
        rule_based_pair_separation(C1, C2, Feature, Separation)
    ; max_list(Deltas, Separation)
    ).

hypothetical_answers(Answers, Qid, Value, HypAnswers) :-
    exclude_qid(Answers, Qid, Rest),
    HypAnswers = [Qid-Value | Rest].

exclude_qid([], _, []).
exclude_qid([Qid-_ | Rest], Qid, Out) :-
    !,
    exclude_qid(Rest, Qid, Out).
exclude_qid([H | Rest], Qid, [H | Out]) :-
    exclude_qid(Rest, Qid, Out).

possible_answer_values(enum, Feature, Values) :-
    findall(V, enum_wartosc(Feature, V), Vs),
    ( Vs = [] ->
        Values = [unknown]
    ; Values = Vs
    ).
possible_answer_values(slider, _Feature, [0, 50, 100, unknown]).
possible_answer_values(_Other, _Feature, [unknown]).

% Szybki fallback: różnica oczekiwań z reguł CF dla cechy (gdy symulacja nie rozdziela).
rule_based_pair_separation(C1, C2, Feature, Separation) :-
    country_feature_discriminants(C1, Feature, D1),
    country_feature_discriminants(C2, Feature, D2),
    discriminants_distance(D1, D2, Separation).

country_feature_discriminants(Country, Feature, disc(Signs, Weight)) :-
    findall(W-Sign,
        ( regula_cf(_Rid, Country, Premises, W, _Priority),
          W > 0.15,
          member(P, Premises),
          premise_feature(P, Feature),
          premise_discriminant(P, Sign)
        ),
        Weighted
    ),
    ( Weighted = [] ->
        Signs = [], Weight = 0.0
    ; findall(S, member(_-S, Weighted), Signs),
      findall(W, member(W-_, Weighted), Ws),
      sum_list(Ws, SumW),
      Weight is SumW
    ).

premise_discriminant(cecha(_F, Exp), bool(Exp)).
premise_discriminant(cecha_enum(_F, Val), enum(Val)).
premise_discriminant(cecha_num(_F, Min, Max), num(Min, Max)).

discriminants_distance(disc(S1, W1), disc(S2, W2), Separation) :-
    ( S1 = [], S2 = [] ->
        Separation = 0.0
    ; signs_compatible(S1, S2) ->
        Separation = 0.0
    ; Separation is min(1.0, (W1 + W2) / 2.0)
    ).

signs_compatible(S1, S2) :-
    member(A, S1),
    member(B, S2),
    signs_compatible_pair(A, B),
    !.

signs_compatible_pair(bool(X), bool(X)).
signs_compatible_pair(enum(X), enum(X)).
signs_compatible_pair(num(Min1, Max1), num(Min2, Max2)) :-
    overlap_range(Min1, Max1, Min2, Max2).

overlap_range(Min1, Max1, Min2, Max2) :-
    max(Min1, Min2) =< min(Max1, Max2).

% --- Wybór kolejnego pytania: maksymalna moc separacyjna względem par hipotez ---
next_question(KnownAnswers, _CandidateCountries, QuestionId) :-
    unanswered_questions(KnownAnswers, Unanswered),
    Unanswered \= [],
    unresolved_hypothesis_pairs(KnownAnswers, Pairs),
    ( Pairs = [] ->
        next_question_single_leader(KnownAnswers, Unanswered, QuestionId)
    ; filter_questions_for_pairs(Unanswered, Pairs, CandidateQs),
      ( CandidateQs = [] -> ScorableQs = Unanswered ; ScorableQs = CandidateQs ),
      score_questions_rule_based(ScorableQs, Pairs, Scored),
      keysort(Scored, SortedAsc),
      refine_top_questions(KnownAnswers, Pairs, SortedAsc, QuestionId)
    ).

% Gdy zostaje jeden lider: pytania wzmacniające dowód (cechy z reguł CF lidera).
next_question_single_leader(Answers, Unanswered, QuestionId) :-
    active_hypotheses(Answers, [Leader | _]),
    score_questions_for_leader(Unanswered, Leader, Scored),
    keysort(Scored, SortedAsc),
    reverse(SortedAsc, SortedDesc),
    nth0(0, SortedDesc, _-QuestionId).

score_questions_for_leader([], _, []).
score_questions_for_leader([Qid | Rest], Leader, [Score-Qid | Out]) :-
    pytanie(Qid, Feature, _, _),
    leader_feature_rule_weight(Leader, Feature, W),
    atom_length(Qid, Tie),
    Score is W + Tie / 100000.0,
    score_questions_for_leader(Rest, Leader, Out).

leader_feature_rule_weight(Leader, Feature, Weight) :-
    findall(
        W,
        ( regula_cf(_Rid, Leader, Premises, W, _P),
          premise_mentions_feature(Premises, Feature),
          W > 0.0
        ),
        Ws
    ),
    ( Ws = [] -> Weight = 0.0 ; sum_list(Ws, Weight) ).

filter_questions_for_pairs(Unanswered, Pairs, CandidateQs) :-
    findall(
        Qid,
        ( member(Qid, Unanswered),
          pytanie(Qid, Feature, _, _),
          pairs_relevant_to_feature(Pairs, Feature)
        ),
        Raw
    ),
    sort(Raw, CandidateQs).

% Szybka preselekcja (reguły CF), potem symulacja tylko dla kilku najlepszych kandydatów.
score_questions_rule_based([], _, []).
score_questions_rule_based([Qid | Rest], Pairs, [Score-Qid | ScoredRest]) :-
    rule_based_question_power(Qid, Pairs, Score),
    score_questions_rule_based(Rest, Pairs, ScoredRest).

refine_top_questions(Answers, Pairs, ScoredAsc, QuestionId) :-
    reverse(ScoredAsc, ScoredDesc),
    max_simulation_questions(MaxQ),
    take_scored_questions(ScoredDesc, MaxQ, Top),
    score_questions_simulation(Answers, Top, Pairs, Refined),
    keysort(Refined, Asc),
    last(Asc, _-QuestionId).

take_scored_questions([], _, []).
take_scored_questions(_, 0, []) :- !.
take_scored_questions([H | T], N, [H | Out]) :-
    N > 0,
    N1 is N - 1,
    take_scored_questions(T, N1, Out).

score_questions_simulation(_Answers, [], _, []).
score_questions_simulation(Answers, [Score-Qid | Rest], Pairs, [Final-Qid | Out]) :-
    simulation_question_power(Qid, Answers, Pairs, Sim),
    Final is Score + Sim,
    score_questions_simulation(Answers, Rest, Pairs, Out).

premise_mentions_feature(Premises, Feature) :-
    member(Premise, Premises),
    premise_feature(Premise, Feature),
    !.

% --- API kontekstowe (deterministyczne — jedno rozwiązanie) ---
next_contextual_question(KnownAnswers, QuestionId) :-
    active_hypotheses(KnownAnswers, Hypotheses),
    Hypotheses \= [],
    next_question(KnownAnswers, Hypotheses, QuestionId),
    !.

first_score([_-S | _Rest], S) :- !.

sort_scores_desc(Pairs, Desc) :-
    maplist(score_country_flip, Pairs, Flipped),
    keysort(Flipped, AscByScore),
    reverse(AscByScore, DescByScore),
    maplist(score_country_flip, DescByScore, Desc).

score_country_flip(Country-Score, Score-Country).

premise_feature(cecha(Feature, _), Feature).
premise_feature(cecha_enum(Feature, _), Feature).
premise_feature(cecha_num(Feature, _, _), Feature).
