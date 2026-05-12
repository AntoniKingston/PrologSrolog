:- module(inference_engine, [
    infer_scores/2,
    best_country/2,
    explain_country/3
]).

:- use_module(library(lists)).
:- use_module('knowledge_base_template.pl').

% infer_scores(+Answers, -Scores)
% Answers is a list of Id-Value pairs, where Value:
% - bool answers: yes/no/unknown
% - enum answers: atom
% - slider answers: number in [0,100]
infer_scores(Answers, Scores) :-
    findall(Country-Score, (kraj(Country), country_score(Country, Answers, Score)), Scores).

best_country(Answers, BestCountry-BestScore) :-
    infer_scores(Answers, Scores),
    keysort_by_score_desc(Scores, [BestCountry-BestScore | _]).

explain_country(Country, Answers, Explanation) :-
    findall(
        RuleId,
        rule_fired(Country, Answers, RuleId, _Contribution),
        FiredRules
    ),
    findall(
        RuleId,
        rule_blocked_by_veto(Country, Answers, RuleId),
        VetoedRules
    ),
    Explanation = explanation{
        country: Country,
        fired_rules: FiredRules,
        vetoed_rules: VetoedRules
    }.

country_score(Country, Answers, FinalScore) :-
    cf_score(Country, Answers, CfScore),
    fuzzy_score(Country, Answers, FuzzyScore),
    veto_penalty(Country, Answers, Penalty),
    Raw is (0.7 * CfScore) + (0.3 * FuzzyScore) - Penalty,
    clamp_01(Raw, FinalScore).

cf_score(Country, Answers, Score) :-
    findall(
        Contribution,
        rule_fired(Country, Answers, _RuleId, Contribution),
        Contributions
    ),
    sum_list(Contributions, Sum),
    clamp_01(Sum, Score).

rule_fired(Country, Answers, RuleId, Contribution) :-
    regula_cf(RuleId, Country, Premises, Weight, Priority),
    premises_satisfied(Premises, Answers),
    PriorityFactor is min(1.0, Priority / 10.0),
    Contribution is Weight * PriorityFactor.

premises_satisfied([], _Answers).
premises_satisfied([Premise | Rest], Answers) :-
    premise_holds(Premise, Answers),
    premises_satisfied(Rest, Answers).

premise_holds(cecha(Feature, tak), Answers) :-
    answer_for_feature(Feature, Answers, yes).
premise_holds(cecha(Feature, nie), Answers) :-
    answer_for_feature(Feature, Answers, no).
premise_holds(cecha_enum(Feature, Value), Answers) :-
    answer_for_feature(Feature, Answers, Value).
premise_holds(cecha_num(Feature, Min, Max), Answers) :-
    answer_for_feature(Feature, Answers, Number),
    number(Number),
    Number >= Min,
    Number =< Max.

fuzzy_score(Country, Answers, Score) :-
    findall(
        Contribution,
        (regula_fuzzy(_Rid, Country, Feature, Label, Weight),
         answer_for_feature(Feature, Answers, Input),
         number(Input),
         fuzzy_membership(Label, Input, Mu),
         Contribution is Mu * Weight),
        Contributions
    ),
    ( Contributions = [] -> Score = 0.0
    ; sum_list(Contributions, Sum), clamp_01(Sum, Score)
    ).

% Very lightweight fuzzy sets on [0,100].
fuzzy_membership(plaski, X, Mu) :-
    clamp_01((50.0 - X) / 50.0, Mu).
fuzzy_membership(pagorkowaty, X, Mu) :-
    Left is X / 50.0,
    Right is (100.0 - X) / 50.0,
    min_list([Left, Right, 1.0], MinV),
    max(0.0, MinV, Mu).
fuzzy_membership(gorzysty, X, Mu) :-
    clamp_01((X - 50.0) / 50.0, Mu).
fuzzy_membership(_, _X, 0.0).

veto_penalty(Country, Answers, Penalty) :-
    findall(
        P,
        (weto(Country, Premise, Threshold),
         premise_conflict_strength(Premise, Answers, Strength),
         Strength >= Threshold,
         P = 0.5),
        Penalties
    ),
    sum_list(Penalties, Raw),
    clamp_01(Raw, Penalty).

rule_blocked_by_veto(Country, Answers, RuleId) :-
    regula_cf(RuleId, Country, _Premises, _Weight, _Priority),
    weto(Country, Premise, Threshold),
    premise_conflict_strength(Premise, Answers, Strength),
    Strength >= Threshold.

premise_conflict_strength(cecha(Feature, tak), Answers, Strength) :-
    (answer_for_feature(Feature, Answers, no) -> Strength = 1.0 ; Strength = 0.0).
premise_conflict_strength(cecha(Feature, nie), Answers, Strength) :-
    (answer_for_feature(Feature, Answers, yes) -> Strength = 1.0 ; Strength = 0.0).
premise_conflict_strength(cecha_enum(Feature, Expected), Answers, Strength) :-
    ( answer_for_feature(Feature, Answers, Actual),
      Actual \= Expected -> Strength = 1.0 ; Strength = 0.0
    ).
premise_conflict_strength(cecha_num(Feature, Min, Max), Answers, Strength) :-
    ( answer_for_feature(Feature, Answers, Actual),
      number(Actual),
      (Actual < Min ; Actual > Max) -> Strength = 1.0 ; Strength = 0.0
    ).

answer_for_feature(Feature, Answers, Value) :-
    pytanie(QuestionId, Feature, _InputType, _Context),
    memberchk(QuestionId-Value, Answers).

clamp_01(X, Clamped) :-
    (X < 0.0 -> Clamped = 0.0
    ; X > 1.0 -> Clamped = 1.0
    ; Clamped = X).

keysort_by_score_desc(Pairs, SortedDesc) :-
    maplist(flip_pair, Pairs, Flipped),
    keysort(Flipped, SortedAscByScore),
    reverse(SortedAscByScore, Reversed),
    maplist(flip_pair, Reversed, SortedDesc).

flip_pair(A-B, B-A).
