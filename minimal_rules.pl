:- module(minimal_rules, [
    all_condition_attributes/1,
    decision_table/1,
    core_features/1,
    core_attributes/1,
    find_reduct/1,
    all_reducts/1,
    minimal_rules_for_country/2,
    print_decision_table/0,
    print_minimal_report/0
]).

:- use_module(library(lists)).
:- use_module('knowledge_base_template.pl').

% Maks. liczba atrybutów do pełnego przeszukania wszystkich reduktów.
max_exact_reduct_search_attributes(16).

% =============================================================================
% Tablica decyzyjna: wiersze = kraje (decyzje), kolumny = atrybuty warunkowe
% =============================================================================

all_condition_attributes(Attributes) :-
    findall(
        Feature,
        ( regula_cf(_Rid, _Country, Premises, _W, _P),
          member(Premise, Premises),
          premise_feature(Premise, Feature)
        ),
        Raw
    ),
    sort(Raw, Attributes).

decision_table(Rows) :-
    all_condition_attributes(Attributes),
    findall(
        row(Country, Cells),
        ( kraj(Country),
          decision_table_cells(Country, Attributes, Cells)
        ),
        Rows
    ).

decision_table_cells(Country, Attributes, Cells) :-
    findall(
        cell(Feature, Signature),
        ( member(Feature, Attributes),
          attribute_signature(Country, Feature, Signature)
        ),
        Cells
    ).

% Sygnatura atrybutu kraju (z reguł CF) — lista wartości bool/enum/range.
attribute_signature(Country, Feature, Signature) :-
    findall(
        Sig,
        ( regula_cf(_Rid, Country, Premises, _W, _P),
          member(Premise, Premises),
          premise_feature(Premise, Feature),
          premise_signature(Premise, Sig)
        ),
        Raw
    ),
    sort(Raw, Signature).

premise_signature(cecha(_F, Value), bool(Value)).
premise_signature(cecha_enum(_F, Value), enum(Value)).
premise_signature(cecha_num(_F, Min, Max), range(Min, Max)).

% =============================================================================
% Rdzeń (core): atrybuty niezbędne — bez nich pary krajów nie są rozróżnialne
% =============================================================================

core_attributes(Core) :-
    all_condition_attributes(All),
    length(All, N),
    max_exact_reduct_search_attributes(MaxN),
    ( N =< MaxN ->
        all_reducts_exact(All, Reducts),
        reducts_intersection(Reducts, Core)
    ;
        findall(
            Attr,
            ( member(Attr, All),
              indispensable_attribute(Attr)
            ),
            Core
        )
    ).

% Zgodność wsteczna z poprzednim API.
core_features(Core) :-
    core_attributes(Core).

indispensable_attribute(Attr) :-
    all_condition_attributes(All),
    subtract(All, [Attr], Without),
    \+ discriminates_all_pairs(Without).

% =============================================================================
% Redukty: minimalne zbiory atrybutów zachowujące rozróżnialność decyzji
% =============================================================================

find_reduct(Reduct) :-
    core_attributes(Core),
    all_condition_attributes(All),
    extend_to_reduct(Core, All, Extended),
    minimize_reduct(Extended, Reduct).

% Rozszerz rdzeń o atrybuty, aż wszystkie pary krajów będą rozróżnione.
extend_to_reduct(Current, _All, Current) :-
    discriminates_all_pairs(Current),
    !.
extend_to_reduct(Current, All, Reduct) :-
    select_helpful_attribute(Current, All, Attr),
    !,
    extend_to_reduct([Attr | Current], All, Reduct).
extend_to_reduct(Current, _All, Current).

select_helpful_attribute(Current, All, BestAttr) :-
    findall(
        Gain-Attr,
        ( member(Attr, All),
          \+ memberchk(Attr, Current),
          attribute_discrimination_gain(Current, Attr, Gain),
          Gain > 0
        ),
        Keyed
    ),
    Keyed \= [],
    keysort(Keyed, Sorted),
    last(Sorted, _-BestAttr).

% Ile par krajów staje się rozróżnialnych po dodaniu atrybutu.
attribute_discrimination_gain(Current, Attr, Gain) :-
    findall(
        1,
        ( kraj(C1),
          kraj(C2),
          C1 @< C2,
          \+ countries_differ_on_attributes(C1, C2, Current),
          countries_differ_on_attribute(C1, C2, Attr)
        ),
        Pairs
    ),
    length(Pairs, Gain).

minimize_reduct(Set, Minimized) :-
    sort(Set, Sorted),
    minimize_reduct_loop(Sorted, Minimized).

minimize_reduct_loop(Set, Minimized) :-
    ( member(Attr, Set),
      subtract(Set, [Attr], Smaller),
      Smaller \= [],
      discriminates_all_pairs(Smaller)
    ->
        minimize_reduct_loop(Smaller, Minimized)
    ;
        sort(Set, Minimized)
    ).

% Wszystkie redukty (dokładnie przy małej liczbie atrybutów; inaczej przybliżenie).
all_reducts(Reducts) :-
    all_condition_attributes(All),
    length(All, N),
    max_exact_reduct_search_attributes(MaxN),
    ( N =< MaxN ->
        all_reducts_exact(All, Reducts)
    ;
        find_reduct(R),
        Reducts = [R]
    ).

all_reducts_exact(All, Reducts) :-
    findall(
        Attr,
        ( member(Attr, All),
          indispensable_attribute(Attr)
        ),
        Core
    ),
    findall(
        Candidate,
        ( subset_with_core(All, Core, Candidate),
          discriminates_all_pairs(Candidate),
          \+ proper_reduct_subset_exists(Candidate)
        ),
        Raw
    ),
    sort(Raw, Reducts).

reducts_intersection([R], R).
reducts_intersection([R1, R2 | Rest], Core) :-
    intersection(R1, R2, Inter),
    reducts_intersection([Inter | Rest], Core).
reducts_intersection([], []).

subset_with_core(All, Core, Subset) :-
    all_subsets(All, Subsets),
    member(Subset, Subsets),
    is_subset(Core, Subset).

all_subsets([], [[]]).
all_subsets([X | Xs], Subsets) :-
    all_subsets(Xs, TailSubs),
    findall([X | S], member(S, TailSubs), WithX),
    append(WithX, TailSubs, Subsets).

proper_reduct_subset_exists(Candidate) :-
    all_subsets(Candidate, Subsets),
    member(Smaller, Subsets),
    Smaller \= [],
    Smaller \= Candidate,
    discriminates_all_pairs(Smaller).

discriminates_all_pairs(Attributes) :-
    forall(
        ( kraj(C1),
          kraj(C2),
          C1 @< C2
        ),
        countries_differ_on_attributes(C1, C2, Attributes)
    ).

countries_differ_on_attributes(C1, C2, Attributes) :-
    member(Attr, Attributes),
    countries_differ_on_attribute(C1, C2, Attr),
    !.

countries_differ_on_attribute(C1, C2, Attr) :-
    attribute_signature(C1, Attr, Sig1),
    attribute_signature(C2, Attr, Sig2),
    Sig1 \= Sig2.

% =============================================================================
% Reguły minimalne: unikalne dla kraju, tylko atrybuty z reduktu, bez zbędnych przesłanek
% =============================================================================

minimal_rules_for_country(Country, MinimalRules) :-
    country_condition_attributes(Country, CountryAttrs),
    find_reduct(GlobalReduct),
    union_sorted(CountryAttrs, GlobalReduct, ContextAttrs),
    findall(
        rule(RuleId, Premises, Weight, Priority),
        ( regula_cf(RuleId, Country, FullPrem, Weight, Priority),
          minimal_unique_premises(Country, FullPrem, Premises),
          premises_in_attributes(Premises, ContextAttrs)
        ),
        MinimalRules
    ).

country_condition_attributes(Country, Attributes) :-
    findall(
        Feature,
        ( regula_cf(_Rid, Country, Premises, _W, _P),
          member(Premise, Premises),
          premise_feature(Premise, Feature)
        ),
        Raw
    ),
    sort(Raw, Attributes).

% Minimalny (nieusuwalny) podzbiór przesłanek unikalnie identyfikujący kraj.
minimal_unique_premises(Country, FullPrem, Prem) :-
    nonempty_premise_subsets(FullPrem, Prem),
    rule_unique_for_country(Country, Prem),
    minimal_premise_set(Country, Prem).

nonempty_premise_subsets(Premises, Subset) :-
    all_premise_subsets(Premises, Subsets),
    member(Subset, Subsets),
    Subset \= [].

all_premise_subsets([], [[]]).
all_premise_subsets([H | T], Subsets) :-
    all_premise_subsets(T, TailSubs),
    findall([H | S], member(S, TailSubs), WithH),
    append(WithH, TailSubs, Subsets).

union_sorted(A, B, Union) :-
    append(A, B, Combined),
    sort(Combined, Union).

premises_in_attributes(Premises, Attributes) :-
    forall(
        ( member(Premise, Premises),
          premise_feature(Premise, Feature)
        ),
        memberchk(Feature, Attributes)
    ).

rule_unique_for_country(Country, Premises) :-
    \+ (
        kraj(Other),
        Other \= Country,
        country_satisfies_premises(Other, Premises)
    ).

country_satisfies_premises(Country, Premises) :-
    forall(member(Premise, Premises), country_satisfies_premise(Country, Premise)).

country_satisfies_premise(Country, Premise) :-
    premise_feature(Premise, Feature),
    attribute_signature(Country, Feature, Signature),
    Signature \= [],
    premise_matches_signature(Premise, Signature).

premise_matches_signature(cecha(_F, Value), Signature) :-
    memberchk(bool(Value), Signature).
premise_matches_signature(cecha_enum(_F, Value), Signature) :-
    memberchk(enum(Value), Signature).
premise_matches_signature(cecha_num(_F, Min, Max), Signature) :-
    memberchk(range(Min, Max), Signature).

minimal_premise_set(Country, Premises) :-
    \+ (
        append(Before, [_ | After], Premises),
        append(Before, After, Smaller),
        Smaller \= [],
        rule_unique_for_country(Country, Smaller)
    ).

% =============================================================================
% Raporty diagnostyczne
% =============================================================================

print_decision_table :-
    all_condition_attributes(Attrs),
    length(Attrs, NumAttrs),
    format("=== TABLICA DECYZYJNA (~w atrybutów) ===~n", [NumAttrs]),
    forall(
        ( kraj(Country),
          attribute_signature_row(Country, Attrs, Parts),
          atomic_list_concat(Parts, " | ", Line)
        ),
        format("~w: ~w~n", [Country, Line])
    ),
    nl.

attribute_signature_row(_Country, [], []).
attribute_signature_row(Country, [Attr | Rest], [Part | Parts]) :-
    ( attribute_signature(Country, Attr, Sig) ->
        signature_to_atom(Sig, Part)
    ; Part = '-'
    ),
    attribute_signature_row(Country, Rest, Parts).

signature_to_atom([], '-') :- !.
signature_to_atom(Sig, Text) :-
    findall(Token, (member(S, Sig), sig_token(S, Token)), Tokens),
    atomic_list_concat(Tokens, ",", Text).

sig_token(bool(V), V).
sig_token(enum(V), V).
sig_token(range(Min, Max), Token) :-
    format(string(Token), "~w..~w", [Min, Max]).

print_minimal_report :-
    all_condition_attributes(All),
    length(All, NumAll),
    core_attributes(Core),
    length(Core, NumCore),
    find_reduct(Reduct),
    length(Reduct, NumReduct),
    all_reducts(Reducts),
    length(Reducts, NumReducts),
    format("=== MODUŁ REGUŁ MINIMALNYCH (tablica decyzyjna + redukty) ===~n"),
    format("Atrybuty warunkowe: ~w~n", [NumAll]),
    format("Rdzeń (core) [~w]: ~w~n", [NumCore, Core]),
    format("Redukt [~w]: ~w~n", [NumReduct, Reduct]),
    format("Liczba reduktów (dokładna lub przybliżona): ~w~n", [NumReducts]),
    nl,
    print_decision_table,
    forall(
        kraj(Country),
        (
            format("=== REGUŁY MINIMALNE: ~w ===~n", [Country]),
            ( minimal_rules_for_country(Country, Rules) ->
                length(Rules, NR),
                format("  (liczba: ~w)~n", [NR]),
                forall(member(R, Rules), print_rule(R))
            ; format("  Brak reguł minimalnych.~n", [])
            ),
            nl
        )
    ).

print_rule(rule(RuleId, Premises, Weight, Priority)) :-
    format("  ~w | w=~2f | pri=~w~n", [RuleId, Weight, Priority]),
    format("    przesłanki: ~w~n", [Premises]).

premise_feature(cecha(Feature, _), Feature).
premise_feature(cecha_enum(Feature, _), Feature).
premise_feature(cecha_num(Feature, _, _), Feature).

is_subset([], _).
is_subset([H | T], Set) :-
    memberchk(H, Set),
    is_subset(T, Set).
