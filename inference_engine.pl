:- module(inference_engine, [
    infer_scores/2,
    best_country/2,
    explain_country/3,
    clear_hipotezy/0,
    rebuild_hipotezy/1,
    hipoteza/2,
    wynik_koncowy/2
]).

:- use_module(library(lists)).
:- use_module('knowledge_base_template.pl').

% Konkluzje dynamiczne (konspekt §4.2) — nie są faktami w bazie wiedzy.
:- dynamic hipoteza/2.

% Domyślne wagi hybrydy §7.3: CF + fuzzy + reguły kontekstowe − weta.
default_cf_weight(0.55).
default_fuzzy_weight(0.30).
default_context_weight(0.15).

% Pewność przesłanki przy odpowiedzi „nie wiem”.
unknown_premise_certainty(0.5).

% Próg weto, gdy użytkownik wskazał język niebędący urzędowym w danym kraju.
language_veto_threshold(0.78).

% infer_scores(+Answers, -Scores)
% Wyniki po konkurencji między krajami: udział Raw_i / suma(Raw_j) (suma ≈ 1.0).
% Po obliczeniu odświeża dynamiczne hipoteza/2 (konspekt §4.2).
infer_scores(Answers, Scores) :-
    compute_infer_scores(Answers, Scores),
    sync_hipotezy(Scores).

compute_infer_scores(Answers, Scores) :-
    findall(Country-Raw, (kraj(Country), country_score(Country, Answers, Raw)), Raws),
    dedupe_country_raw_scores(Raws, Deduped),
    competitive_country_scores(Deduped, Scores).

% --- Hipotezy i wynik końcowy (konspekt: konkluzje konstruowane w trakcie wnioskowania) ---
clear_hipotezy :-
    retractall(hipoteza(_, _)).

rebuild_hipotezy(Answers) :-
    infer_scores(Answers, _).

sync_hipotezy(Scores) :-
    clear_hipotezy(),
    forall(member(Country-Score, Scores), assertz(hipoteza(Country, Score))).

% wynik_koncowy(+Kraj, +Pewnosc) — najlepsza hipoteza spośród aktualnie zaassertowanych.
wynik_koncowy(Kraj, Pewnosc) :-
    findall(P-K, hipoteza(K, P), Pairs),
    Pairs \= [],
    keysort(Pairs, Asc),
    last(Asc, Pewnosc-Kraj).

% Jedna wartość Raw na kraj (zabezpieczenie przed wielokrotnym sukcesem podpredykatów).
dedupe_country_raw_scores(Raws, Deduped) :-
    findall(Country, kraj(Country), Countries),
    maplist(max_raw_for_country(Raws), Countries, Deduped).

max_raw_for_country(Raws, Country, Country-MaxRaw) :-
    findall(R, member(Country-R, Raws), Rs),
    ( Rs = [] -> MaxRaw = 0.0 ; max_list(Rs, MaxRaw) ).

best_country(Answers, BestCountry-BestScore) :-
    rebuild_hipotezy(Answers),
    wynik_koncowy(BestCountry, BestScore),
    !.

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
    cf_negative_score(Country, Answers, CfNeg),
    fuzzy_score(Country, Answers, FuzzyScore),
    contextual_score(Country, Answers, CtxScore),
    hybrid_weights(Country, Answers, Wcf, Wfz, Wctx),
    Explanation = explanation{
        country: Country,
        fired_rules: FiredRules,
        vetoed_rules: VetoedRules,
        cf_score: CfScore,
        cf_negative: CfNeg,
        fuzzy_score: FuzzyScore,
        contextual_score: CtxScore,
        weight_cf: Wcf,
        weight_fuzzy: Wfz,
        weight_context: Wctx
    }.

% --- Wynik kraju §7.3: CF + fuzzy + kontekst − weta, potem wyostrzanie ---
country_score(Country, Answers, FinalScore) :-
    cf_score(Country, Answers, CfScore),
    fuzzy_score(Country, Answers, FuzzyScore),
    contextual_score(Country, Answers, CtxScore),
    hybrid_weights(Country, Answers, Wcf, Wfz, Wctx),
    veto_penalty(Country, Answers, Penalty),
    Raw is (Wcf * CfScore) + (Wfz * FuzzyScore) + (Wctx * CtxScore) - Penalty,
    sharpen_score(Raw, Sharpened),
    clamp_01(Sharpened, FinalScore).

% Wagi zależne od liczby trafień CF / fuzzy / kontekstowych.
hybrid_weights(Country, Answers, Wcf, Wfz, Wctx) :-
    count_cf_rule_hits(Country, Answers, Ncf),
    count_fuzzy_rule_hits(Country, Answers, Nfz),
    count_contextual_hits(Country, Answers, Nctx),
    blend_hybrid_weights(Ncf, Nfz, Nctx, Wcf, Wfz, Wctx).

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

blend_hybrid_weights(Ncf, Nfz, Nctx, Wcf, Wfz, Wctx) :-
    Total is Ncf + Nfz + Nctx,
    ( Total < 0.001 ->
        default_cf_weight(Wcf),
        default_fuzzy_weight(Wfz),
        default_context_weight(Wctx)
    ; Wcf is Ncf / Total,
      Wfz is Nfz / Total,
      Wctx is Nctx / Total
    ).

count_contextual_hits(Country, Answers, N) :-
    answered_contexts(Answers, Contexts),
    Contexts \= [],
    findall(
        1,
        ( member(Ctx, Contexts),
          regula_cf(_Rid, Country, Premises, _W, _P),
          rule_premises_in_context(Premises, Ctx),
          premises_cf(Premises, Answers, CF),
          CF >= 0.5
        ),
        L
    ),
    length(L, N).
count_contextual_hits(_Country, _Answers, 0).

% --- CF §7.1: dowody dodatnie (MYCIN) minus ujemne (sprzeczne przesłanki) ---
cf_score(Country, Answers, Score) :-
    cf_positive_score(Country, Answers, Pos),
    cf_negative_score(Country, Answers, Neg),
    Raw is Pos - Neg,
    clamp_01(Raw, Score).

cf_positive_score(Country, Answers, Score) :-
    findall(
        RuleCF,
        rule_fired(Country, Answers, _RuleId, RuleCF),
        RuleCFs
    ),
    combine_cfs_mycin(RuleCFs, Score).

% Dowody ujemne: reguły z częściowo / całkowicie niespełnionymi przesłankami.
cf_negative_score(Country, Answers, Neg) :-
    findall(
        Penalty,
        ( regula_cf(_Rid1, Country, Premises, Weight, Priority),
          premises_cf(Premises, Answers, PremiseCF),
          PremiseCF < 0.5,
          PremiseCF > 0.0,
          rule_has_answered_premise_failure(Premises, Answers),
          PriorityFactor is min(1.0, Priority / 10.0),
          Penalty is Weight * PriorityFactor * (1.0 - PremiseCF)
        ),
        WeakPenalties
    ),
    findall(
        Penalty,
        ( regula_cf(_Rid2, Country, Premises, Weight, Priority),
          premises_cf(Premises, Answers, PremiseCF),
          PremiseCF =< 0.01,
          rule_has_answered_premise_failure(Premises, Answers),
          PriorityFactor is min(1.0, Priority / 10.0),
          Penalty is Weight * PriorityFactor * 0.85
        ),
        StrongPenalties
    ),
    append(WeakPenalties, StrongPenalties, All),
    sum_list(All, Sum),
    clamp_01(Sum, Neg).

rule_fired(Country, Answers, RuleId, RuleCF) :-
    regula_cf(RuleId, Country, Premises, Weight, Priority),
    premises_cf(Premises, Answers, PremiseCF),
    PremiseCF > 0.01,
    PriorityFactor is min(1.0, Priority / 10.0),
    rule_competition_divisor(Premises, Answers, Divisor),
    ScaledWeight is Weight / Divisor,
    RuleCF is ScaledWeight * PriorityFactor * PremiseCF.

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
    ; answer_for_feature(Feature, Answers, nie_wiem) ->
        unknown_premise_certainty(Cert)
    ; answer_for_feature(Feature, Answers, Expected) ->
        Cert = 1.0
    ; answer_for_feature(Feature, Answers, _) ->
        Cert = 0.0
    ; Cert = 0.0
    ).

feature_answered(Feature, Answers) :-
    pytanie(Qid, Feature, _, _),
    memberchk(Qid-_, Answers),
    !.

% Kara CF tylko gdy użytkownik podał wartość sprzeczną z przesłanką (nie gdy pytanie nie padło).
rule_has_answered_premise_failure(Premises, Answers) :-
    member(Premise, Premises),
    premise_feature(Premise, Feature),
    feature_answered(Feature, Answers),
    premise_certainty(Premise, Answers, Cert),
    Cert < 0.5,
    !.

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

% --- Rozmytość §7.2: Mamdani → agregacja max → defuzyfikacja (środek ciężkości) ---
fuzzy_score(Country, Answers, Score) :-
    findall(
        FeatureScore,
        ( cecha_typ(Feature, fuzzy),
          answer_for_feature(Feature, Answers, Input),
          number(Input),
          mamdani_defuzzify_feature(Country, Feature, Input, Answers, FeatureScore),
          FeatureScore > 0.001
        ),
        FeatureScores
    ),
    ( FeatureScores = [] ->
        Score = 0.0
    ; max_list(FeatureScores, Raw),
      sharpen_score(Raw, Score)
    ).

% Mamdani: aktywacja reguł, agregacja MAX na uniwersum [0,100], COG, normalizacja do [0,1].
mamdani_defuzzify_feature(Country, Feature, Input, Answers, Score01) :-
    findall(
        fuzzy_act(Label, Alpha),
        ( regula_fuzzy(_Rid, Country, Feature, Label, Weight),
          fuzzy_membership(Feature, Label, Input, Mu),
          mamdani_activation(Mu, Weight, RawAlpha),
          competing_countries_for_fuzzy(Feature, Label, Answers, Competitors),
          Alpha is RawAlpha / Competitors,
          Alpha > 0.001
        ),
        Activations
    ),
    ( Activations = [] ->
        Score01 = 0.0
    ; centroid_cog(Activations, Feature, Cog),
      Score01 is Cog / 100.0
    ).

mamdani_activation(Mu, Weight, Activation) :-
    Activation is min(Mu, Weight).

centroid_cog(Activations, Feature, Cog) :-
    cog_sample_points(Points),
    cog_accumulate(Points, Activations, Feature, 0.0, 0.0, Num, Den),
    ( Den > 0.0001 -> Cog is Num / Den ; Cog = 0.0 ).

cog_sample_points([0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]).

cog_accumulate([], _, _, Num, Den, Num, Den).
cog_accumulate([Y | Rest], Activations, Feature, Num0, Den0, Num, Den) :-
    mamdani_aggregated_mu(Y, Activations, Feature, MuY),
    Num1 is Num0 + Y * MuY,
    Den1 is Den0 + MuY,
    cog_accumulate(Rest, Activations, Feature, Num1, Den1, Num, Den).

% Agregacja Mamdani (max) przyciętych funkcji przynależności.
mamdani_aggregated_mu(Y, Activations, Feature, MuAgg) :-
    findall(
        MuClip,
        ( member(fuzzy_act(Label, Alpha), Activations),
          linguistic_mu_at(Feature, Label, Y, MuLabel),
          MuClip is min(Alpha, MuLabel),
          MuClip > 0.0
        ),
        Clipped
    ),
    ( Clipped = [] -> MuAgg = 0.0 ; max_list(Clipped, MuAgg) ).

% Funkcje przynależności: trójkąt (plaski, gorzysty) i trapez (pagorkowaty).
fuzzy_membership(Feature, Label, X, Mu) :-
    linguistic_mu_at(Feature, Label, X, Mu).

linguistic_mu_at(_Feature, Label, X, Mu) :-
    linguistic_mu(Label, X, Mu).

linguistic_mu(Label, X, Mu) :-
    ( label_alias(Label, Canonical) -> true ; Canonical = Label ),
    linguistic_shape(Canonical, Shape),
    shape_mu(Shape, X, Mu).

label_alias(niski, plaski).
label_alias(sredni, pagorkowaty).
label_alias(wysoki, gorzysty).

% plaski / gorzysty: trójkąt; pagorkowaty: trapez (płaskie plateau).
linguistic_shape(plaski, triangle(0, 0, 55)).
linguistic_shape(pagorkowaty, trapez(15, 30, 70, 85)).
linguistic_shape(gorzysty, triangle(45, 100, 100)).
linguistic_shape(_Other, triangle(0, 50, 100)).

shape_mu(triangle(A, B, C), X, Mu) :-
    triangle_mu(A, B, C, X, Mu).
shape_mu(trapez(A, B, C, D), X, Mu) :-
    trapez_mu(A, B, C, D, X, Mu).

triangle_mu(_A, B, _C, X, 1.0) :-
    X =:= B,
    !.
triangle_mu(A, B, _C, X, Mu) :-
    X >= A,
    X =< B,
    B > A,
    !,
    Mu is (X - A) / (B - A).
triangle_mu(_A, B, C, X, Mu) :-
    X > B,
    X =< C,
    C > B,
    !,
    Mu is (C - X) / (C - B).
triangle_mu(_, _, _, _, 0.0).

trapez_mu(A, B, C, D, X, Mu) :-
    ( X =< A -> Mu = 0.0
    ; X < B -> Mu is (X - A) / (B - A)
    ; X =< C -> Mu = 1.0
    ; X < D -> Mu is (D - X) / (D - C)
    ; Mu = 0.0
    ).

% --- Reguły kontekstowe §7.3: wzmocnienie reguł CF z aktywnego kontekstu dialogu ---
contextual_score(Country, Answers, Score) :-
    answered_contexts(Answers, Contexts),
    ( Contexts = [] ->
        Score = 0.0
    ; findall(
          Contrib,
          ( member(Ctx, Contexts),
            regula_cf(_Rid, Country, Premises, Weight, Priority),
            rule_premises_in_context(Premises, Ctx),
            premises_cf(Premises, Answers, CF),
            CF >= 0.5,
            PriorityFactor is min(1.0, Priority / 10.0),
            Contrib is Weight * PriorityFactor * CF * 0.35
          ),
          Contribs
      ),
      ( Contribs = [] ->
          Score = 0.0
      ; sum_list(Contribs, Sum),
        clamp_01(Sum, Score)
      )
    ).

answered_contexts(Answers, Contexts) :-
    findall(
        Ctx,
        ( member(Qid-_, Answers),
          pytanie(Qid, _Feature, _Type, Ctx)
        ),
        Raw
    ),
    sort(Raw, Contexts).

rule_premises_in_context(Premises, Ctx) :-
    member(Premise, Premises),
    premise_feature(Premise, Feature),
    pytanie(_Qid, Feature, _Type, Ctx),
    !.

premise_feature(cecha(Feature, _), Feature).
premise_feature(cecha_enum(Feature, _), Feature).
premise_feature(cecha_num(Feature, _, _), Feature).

% Wyostrzanie wyniku (funkcja S-kształtna na [0,1]).
sharpen_score(X, Y) :-
    clamp_01(X, Xc),
    Y is Xc * Xc * (3.0 - 2.0 * Xc).

% --- Weta ---
veto_penalty(Country, Answers, Penalty) :-
    language_veto_threshold(LangThreshold),
    findall(
        P,
        ( ( weto(Country, Premise, Threshold),
            premise_conflict_strength(Premise, Answers, Strength),
            Strength >= Threshold,
            P = 0.5
          )
        ; ( weto_zakaz(Country, Feature, Forbidden, Threshold),
            zakaz_conflict_strength(Feature, Forbidden, Answers, Strength),
            Strength >= Threshold,
            P = 0.5
          )
        ; ( language_zakaz_conflict_strength(Country, Answers, Strength),
            Strength >= LangThreshold,
            P = 0.5
          )
        ),
        Penalties
    ),
    sum_list(Penalties, Raw),
    clamp_01(Raw, Penalty).

% Obserwowany język na znakach nie jest urzędowy w kraju (wielojęzyczność: wiele faktów jezyk_urzedowy_kraju/2).
language_zakaz_conflict_strength(Country, Answers, Strength) :-
    answer_for_feature(jezyk_na_znakach, Answers, Observed),
    language_observation_for_veto(Observed),
    ( jezyk_urzedowy_kraju(Country, Observed) ->
        Strength = 0.0
    ; Strength = 1.0
    ).

language_observation_for_veto(Lang) :-
    Lang \= unknown,
    Lang \= nie_wiem,
    Lang \= inny.

zakaz_conflict_strength(Feature, Forbidden, Answers, Strength) :-
    ( answer_for_feature(Feature, Answers, unknown) -> Strength = 0.0
    ; answer_for_feature(Feature, Answers, nie_wiem) -> Strength = 0.0
    ; answer_for_feature(Feature, Answers, Forbidden) -> Strength = 1.0
    ; Strength = 0.0
    ).

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

% Dzielnik wagi reguły: 1/N (odwrotna proporcjonalność do liczby krajów „powiązanych”).
% Pojedyncza przesłanka enum (np. język): N = kraje mające tę wartość w dowolnej regule CF.
% Wiele przesłanek: N = kraje z identyczną listą przesłanek pasującą do odpowiedzi.
rule_competition_divisor(Premises, Answers, Divisor) :-
    Premises = [cecha_enum(Feature, Value)],
    premises_cf(Premises, Answers, PremiseCF),
    PremiseCF > 0.01,
    !,
    enum_value_country_count(Feature, Value, Divisor).
rule_competition_divisor(Premises, Answers, Divisor) :-
    competing_countries_for_premises(Premises, Answers, Divisor).

% Kraje powiązane z wartością cechy enum (niezależnie od pozostałych przesłanek reguły).
enum_value_country_count(Feature, Value, N) :-
    findall(
        Country,
        ( kraj(Country),
          regula_cf(_Rid, Country, RulePremises, _W, _P),
          member(cecha_enum(Feature, Value), RulePremises)
        ),
        Countries
    ),
    sort(Countries, Unique),
    length(Unique, Count),
    N is max(1, Count).

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
