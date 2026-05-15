:- module(inference_engine, [
    infer_scores/2,
    best_country/2,
    explain_country/3
]).

:- use_module(library(lists)).
:- use_module('knowledge_base_template.pl').

% Domyślne wagi hybrydy (gdy brak dowodów jednego typu).
default_cf_weight(0.65).
default_fuzzy_weight(0.35).

% Pewność przesłanki przy odpowiedzi „nie wiem”.
unknown_premise_certainty(0.5).

% infer_scores(+Answers, -Scores)
% Wyniki po konkurencji między krajami: udział Raw_i / suma(Raw_j) (suma ≈ 1.0).
% Przy wielu równie pasujących krajach pewność każdego spada (nie skalujemy do max=1).
infer_scores(Answers, Scores) :-
    findall(Country-Raw, (kraj(Country), country_score(Country, Answers, Raw)), Raws),
    competitive_country_scores(Raws, Scores).

best_country(Answers, BestCountry-BestScore) :-
    infer_scores(Answers, Scores),
    keysort_by_score_desc(Scores, [BestCountry-BestScore | _]).

explain_country(Country, Answers, Explanation) :-
    findall(
        RuleId,
        rule_fired(Country, Answers, RuleId, _CF),
        FiredRules
    ),
    findall(
        RuleId,
        rule_blocked_by_veto(Country, Answers, RuleId),
        VetoedRules
    ),
    cf_score(Country, Answers, CfScore),
    fuzzy_score(Country, Answers, FuzzyScore),
    hybrid_weights(Country, Answers, Wcf, Wfz),
    Explanation = explanation{
        country: Country,
        fired_rules: FiredRules,
        vetoed_rules: VetoedRules,
        cf_score: CfScore,
        fuzzy_score: FuzzyScore,
        weight_cf: Wcf,
        weight_fuzzy: Wfz
    }.

% --- Wynik kraju: hybryda CF + rozmyte - weta ---
country_score(Country, Answers, FinalScore) :-
    cf_score(Country, Answers, CfScore),
    fuzzy_score(Country, Answers, FuzzyScore),
    hybrid_weights(Country, Answers, Wcf, Wfz),
    veto_penalty(Country, Answers, Penalty),
    Raw is (Wcf * CfScore) + (Wfz * FuzzyScore) - Penalty,
    clamp_01(Raw, FinalScore).

% Wagi zależne od liczby aktywnych reguł CF vs rozmytych dla danego kraju i odpowiedzi.
hybrid_weights(Country, Answers, Wcf, Wfz) :-
    count_fuzzy_rule_hits(Country, Answers, Nfz),
    count_cf_rule_hits(Country, Answers, Ncf),
    blend_hybrid_weights(Ncf, Nfz, Wcf, Wfz).

count_cf_rule_hits(Country, Answers, N) :-
    findall(
        1,
        (regula_cf(_Rid, Country, Premises, _W, _P),
         premises_cf(Premises, Answers, PremiseCF),
         PremiseCF > 0.01),
        L
    ),
    length(L, N).

count_fuzzy_rule_hits(Country, Answers, N) :-
    findall(
        1,
        (regula_fuzzy(_Rid, Country, Feature, Label, _W),
         answer_for_feature(Feature, Answers, Input),
         number(Input),
         fuzzy_membership(Feature, Label, Input, Mu),
         Mu > 0.01),
        L
    ),
    length(L, N).

blend_hybrid_weights(Ncf, Nfz, Wcf, Wfz) :-
    Total is Ncf + Nfz,
    ( Total < 0.001 ->
        default_cf_weight(Wcf),
        default_fuzzy_weight(Wfz)
    ; Wcf is Ncf / Total,
      Wfz is Nfz / Total
    ).

% --- CF (MYCIN): łączenie pewności reguł ---
cf_score(Country, Answers, Score) :-
    findall(
        RuleCF,
        rule_fired(Country, Answers, _RuleId, RuleCF),
        RuleCFs
    ),
    combine_cfs_mycin(RuleCFs, Score).

rule_fired(Country, Answers, RuleId, RuleCF) :-
    regula_cf(RuleId, Country, Premises, Weight, Priority),
    premises_cf(Premises, Answers, PremiseCF),
    PremiseCF > 0.01,
    PriorityFactor is min(1.0, Priority / 10.0),
    RawRuleCF is Weight * PriorityFactor * PremiseCF,
    competing_countries_for_premises(Premises, Answers, Competitors),
    RuleCF is RawRuleCF / Competitors.

% Iloczyn pewności przesłanek (AND w MYCIN).
premises_cf([], _, 1.0).
premises_cf([Premise | Rest], Answers, CF) :-
    premise_certainty(Premise, Answers, C),
    premises_cf(Rest, Answers, RestCF),
    CF is C * RestCF.

% Łączenie CF reguł: CF_new = CF_acc + CF_i * (1 - CF_acc).
combine_cfs_mycin([], 0.0).
combine_cfs_mycin([H | T], Combined) :-
    combine_cfs_mycin(T, Rest),
    mycin_combine(H, Rest, Combined).

mycin_combine(CF1, CF2, Combined) :-
    Combined is CF1 + CF2 * (1.0 - CF1).

% Pewność pojedynczej przesłanki (w tym „nie wiem” = 0.5).
premise_certainty(cecha(Feature, Expected), Answers, Cert) :-
    bool_expected(Expected, WantYes),
    bool_answer_certainty(Feature, Answers, WantYes, Cert).
premise_certainty(cecha_enum(Feature, Value), Answers, Cert) :-
    enum_answer_certainty(Feature, Answers, Value, Cert).
premise_certainty(cecha_num(Feature, Min, Max), Answers, Cert) :-
    numeric_range_certainty(Feature, Answers, Min, Max, Cert).

bool_expected(yes, true).
bool_expected(no, false).
bool_expected(tak, true).
bool_expected(nie, false).

bool_answer_certainty(Feature, Answers, WantYes, Cert) :-
    ( answer_for_feature(Feature, Answers, unknown) ->
        unknown_premise_certainty(Cert)
    ; answer_for_feature(Feature, Answers, yes), WantYes = true -> Cert = 1.0
    ; answer_for_feature(Feature, Answers, no), WantYes = false -> Cert = 1.0
    ; Cert = 0.0
    ).

enum_answer_certainty(Feature, Answers, Expected, Cert) :-
    ( answer_for_feature(Feature, Answers, unknown) ->
        unknown_premise_certainty(Cert)
    ; answer_for_feature(Feature, Answers, Expected) ->
        Cert = 1.0
    ; answer_for_feature(Feature, Answers, _) ->
        Cert = 0.0
    ; Cert = 0.0
    ).

% Miękkie dopasowanie przedziału (trapez na [Min,Max], opad 25 pkt poza zakresem).
numeric_range_certainty(Feature, Answers, _Min, _Max, Cert) :-
    answer_for_feature(Feature, Answers, unknown),
    !,
    unknown_premise_certainty(Cert).
numeric_range_certainty(Feature, Answers, Min, Max, Cert) :-
    answer_for_feature(Feature, Answers, V),
    number(V),
    !,
    range_membership(V, Min, Max, Cert).
numeric_range_certainty(_Feature, _Answers, _Min, _Max, 0.0).

range_membership(V, Min, Max, 1.0) :-
    V >= Min,
    V =< Max,
    !.
range_membership(V, Min, _Max, Cert) :-
    V < Min,
    !,
    D is Min - V,
    Cert is max(0.0, 1.0 - D / 25.0).
range_membership(V, _Min, Max, Cert) :-
    V > Max,
    D is V - Max,
    Cert is max(0.0, 1.0 - D / 25.0).

% Kompatybilność z poprzednim API (reguły sprawdzają premise_holds).
premises_satisfied(Premises, Answers) :-
    premises_cf(Premises, Answers, CF),
    CF >= 0.5.

premise_holds(Premise, Answers) :-
    premise_certainty(Premise, Answers, Cert),
    Cert >= 0.5.

% --- Rozmytość: Mamdani (min aktywacja) + agregacja max + wyostrzanie ---
fuzzy_score(Country, Answers, Score) :-
    findall(
        Activation,
        (regula_fuzzy(_Rid, Country, Feature, Label, Weight),
         answer_for_feature(Feature, Answers, Input),
         number(Input),
         fuzzy_membership(Feature, Label, Input, Mu),
         fuzzy_activation_with_competition(Feature, Label, Answers, Mu, Weight, Activation)),
        Activations
    ),
    ( Activations = [] ->
        Score = 0.0
    ; max_list(Activations, Agg),
      clamp_01(Agg, Score)
    ).

% Reguła Mamdani: aktywacja = min(μ wejścia, wagi reguły).
mamdani_activation(Mu, Weight, Activation) :-
    Activation is min(Mu, Weight).

% Funkcje przynależności etykiet lingwistycznych na [0,100].
% Aliasy semantyczne: niski/sredni/wysoki oraz plaski/pagorkowaty/gorzysty.
fuzzy_membership(_Feature, Label, X, Mu) :-
    linguistic_mu(Label, X, Mu).

linguistic_mu(Label, X, Mu) :-
    ( label_alias(Label, Canonical) -> true ; Canonical = Label ),
    triangle_label_mu(Canonical, X, Mu).

label_alias(niski, plaski).
label_alias(sredni, pagorkowaty).
label_alias(wysoki, gorzysty).

triangle_label_mu(plaski, X, Mu) :-
    clamp_01((50.0 - X) / 50.0, Mu).
triangle_label_mu(pagorkowaty, X, Mu) :-
    Left is X / 50.0,
    Right is (100.0 - X) / 50.0,
    min_list([Left, Right, 1.0], MinV),
    Mu is max(0.0, MinV).
triangle_label_mu(gorzysty, X, Mu) :-
    clamp_01((X - 50.0) / 50.0, Mu).
triangle_label_mu(_Other, _X, 0.0).

% --- Weta ---
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

premise_conflict_strength(cecha(Feature, Expected), Answers, Strength) :-
    bool_expected(Expected, WantYes),
    bool_conflict_strength(Feature, Answers, WantYes, Strength).
premise_conflict_strength(cecha_enum(Feature, Expected), Answers, Strength) :-
    ( answer_for_feature(Feature, Answers, Actual),
      Actual \= Expected -> Strength = 1.0 ; Strength = 0.0
    ).
premise_conflict_strength(cecha_num(Feature, Min, Max), Answers, Strength) :-
    ( answer_for_feature(Feature, Answers, Actual),
      number(Actual),
      (Actual < Min ; Actual > Max) -> Strength = 1.0 ; Strength = 0.0
    ).

bool_conflict_strength(Feature, Answers, WantYes, Strength) :-
    ( answer_for_feature(Feature, Answers, unknown) -> Strength = 0.0
    ; answer_for_feature(Feature, Answers, yes), WantYes = false -> Strength = 1.0
    ; answer_for_feature(Feature, Answers, no), WantYes = true -> Strength = 1.0
    ; Strength = 0.0
    ).

% Liczba krajów z regułą CF o tych samych przesłankach, które pasują do odpowiedzi.
competing_countries_for_premises(Premises, Answers, N) :-
    findall(
        Country,
        (kraj(Country),
         regula_cf(_Rid, Country, Premises, _Weight, _Priority),
         premises_cf(Premises, Answers, PremiseCF),
         PremiseCF > 0.01),
        Countries
    ),
    sort(Countries, Unique),
    length(Unique, Count),
    N is max(1, Count).

% Ta sama cecha+etykieta rozmyta u wielu krajów → dziel aktywację przez liczbę konkurentów.
fuzzy_activation_with_competition(Feature, Label, Answers, Mu, Weight, Activation) :-
    mamdani_activation(Mu, Weight, Raw),
    competing_countries_for_fuzzy(Feature, Label, Answers, Competitors),
    Activation is Raw / Competitors.

competing_countries_for_fuzzy(Feature, Label, Answers, N) :-
    findall(
        Country,
        (kraj(Country),
         regula_fuzzy(_Rid, Country, Feature, Label, _Weight),
         answer_for_feature(Feature, Answers, Input),
         number(Input),
         fuzzy_membership(Feature, Label, Input, Mu),
         Mu > 0.01),
        Countries
    ),
    sort(Countries, Unique),
    length(Unique, Count),
    N is max(1, Count).

% Konkurencja globalna: wynik kraju jako udział w łącznej pewności (nie max=1).
competitive_country_scores([], []).
competitive_country_scores(Raws, Competitive) :-
    findall(R, member(_-R, Raws), Rs),
    sum_positive_scores(Rs, Total),
    ( Total > 0.00001 ->
        maplist(competitive_pair(Total), Raws, Competitive)
    ; Competitive = Raws
    ).

competitive_pair(Total, Country-Raw, Country-Score) :-
    Score is Raw / Total.

sum_positive_scores([], 0.0).
sum_positive_scores([H | T], Total) :-
    ( H > 0.00001 -> Rest is H ; Rest = 0.0 ),
    sum_positive_scores(T, Tail),
    Total is Rest + Tail.

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
