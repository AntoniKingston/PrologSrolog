:- module(minimal_rules, [
    core_features/1,
    minimal_rules_for_country/2,
    print_minimal_report/0
]).

:- use_module(library(lists)).
:- use_module('knowledge_base_template.pl').

% A lightweight prototype:
% - core features are features that occur in CF rules for every country.
% - minimal rules are rules with the shortest premise length per country.

core_features(CoreFeatures) :-
    findall(C, kraj(C), Countries),
    Countries \= [],
    findall(FeatureSet, (member(Country, Countries), country_feature_set(Country, FeatureSet)), FeatureSets),
    intersection_all(FeatureSets, CoreRaw),
    sort(CoreRaw, CoreFeatures).

minimal_rules_for_country(Country, MinimalRules) :-
    findall(
        rule(RuleId, Premises, Weight, Priority),
        regula_cf(RuleId, Country, Premises, Weight, Priority),
        Rules
    ),
    Rules \= [],
    findall(Len-rule(Rid, Prem, W, P),
        (member(rule(Rid, Prem, W, P), Rules), length(Prem, Len)),
        WithLen
    ),
    keysort(WithLen, Sorted),
    Sorted = [MinLen-_|_],
    findall(rule(Rid, Prem, W, P),
        member(MinLen-rule(Rid, Prem, W, P), Sorted),
        MinimalRules
    ).

print_minimal_report :-
    core_features(Core),
    format("=== CORE FEATURES ===~n"),
    forall(member(F, Core), format("- ~w~n", [F])),
    nl,
    forall(
        kraj(Country),
        (
            format("=== MINIMAL RULES FOR ~w ===~n", [Country]),
            ( minimal_rules_for_country(Country, Rules) ->
                forall(member(R, Rules), print_rule(R))
            ; format("No CF rules found.~n", [])
            ),
            nl
        )
    ).

print_rule(rule(RuleId, Premises, Weight, Priority)) :-
    format("Rule: ~w | Weight=~2f | Priority=~w~n", [RuleId, Weight, Priority]),
    format("  Premises: ~w~n", [Premises]).

country_feature_set(Country, FeatureSet) :-
    findall(
        Feature,
        (regula_cf(_Rid, Country, Premises, _Weight, _Priority),
         member(Premise, Premises),
         premise_feature(Premise, Feature)),
        Features
    ),
    sort(Features, FeatureSet).

premise_feature(cecha(Feature, _), Feature).
premise_feature(cecha_enum(Feature, _), Feature).
premise_feature(cecha_num(Feature, _, _), Feature).

intersection_all([Set], Set).
intersection_all([SetA, SetB | Rest], Out) :-
    intersection(SetA, SetB, Inter),
    intersection_all([Inter | Rest], Out).
