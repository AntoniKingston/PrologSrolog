:- module(dialog_strategy, [
    next_question/3,
    unanswered_questions/2
]).

:- use_module('knowledge_base_template.pl').

% unanswered_questions(+KnownAnswers, -QuestionIds)
% KnownAnswers is a list of Id-Value pairs.
unanswered_questions(KnownAnswers, QuestionIds) :-
    findall(
        Id,
        (pytanie(Id, _Feature, _InputType, _Context), \+ memberchk(Id-_, KnownAnswers)),
        QuestionIds
    ).

% next_question(+KnownAnswers, +CandidateCountries, -QuestionId)
% Picks the next unanswered question. Preference is given to questions that
% are more likely to separate the current candidate countries.
next_question(KnownAnswers, CandidateCountries, QuestionId) :-
    unanswered_questions(KnownAnswers, Unanswered),
    Unanswered \= [],
    score_questions(Unanswered, CandidateCountries, Scored),
    keysort(Scored, SortedAsc),
    reverse(SortedAsc, SortedDesc),
    SortedDesc = [_BestScore-QuestionId | _].

score_questions([], _Countries, []).
score_questions([Qid | Rest], Countries, [Score-Qid | ScoredRest]) :-
    question_score(Qid, Countries, Score),
    score_questions(Rest, Countries, ScoredRest).

question_score(Qid, Countries, Score) :-
    pytanie(Qid, Feature, _InputType, _Context),
    count_rules_using_feature(Countries, Feature, Count),
    % A tiny deterministic tie-breaker based on atom length.
    atom_length(Qid, TieBreaker),
    Score is Count + (TieBreaker / 1000.0).

count_rules_using_feature([], _Feature, 0).
count_rules_using_feature([Country | Rest], Feature, Total) :-
    findall(
        1,
        (regula_cf(_Rid, Country, Premises, _Weight, _Priority),
         premise_mentions_feature(Premises, Feature)),
        Matches
    ),
    length(Matches, Here),
    count_rules_using_feature(Rest, Feature, Tail),
    Total is Here + Tail.

premise_mentions_feature(Premises, Feature) :-
    member(Premise, Premises),
    premise_feature(Premise, Feature),
    !.

premise_feature(cecha(Feature, _), Feature).
premise_feature(cecha_enum(Feature, _), Feature).
premise_feature(cecha_num(Feature, _Min, _Max), Feature).
