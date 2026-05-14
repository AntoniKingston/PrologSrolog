:- module(dialog_strategy, [
    next_question/3,
    unanswered_questions/2,
    candidate_countries/2,
    next_contextual_question/2
]).

:- use_module(library(lists)).
:- use_module('knowledge_base_template.pl').
:- use_module(inference_engine, [infer_scores/2]).

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

% candidate_countries(+KnownAnswers, -Countries)
% Countries that still compete for the next question, derived from current
% scores (top cluster around the best score, or all countries if flat).
candidate_countries(Answers, Candidates) :-
    infer_scores(Answers, Scores),
    sort_scores_desc(Scores, Sorted),
    ( Sorted = [] ->
        findall(C, kraj(C), Candidates)
    ; trim_candidates_from_sorted(Sorted, Candidates)
    ).

sort_scores_desc(Pairs, Desc) :-
    maplist(score_country_flip, Pairs, Flipped),
    keysort(Flipped, AscByScore),
    reverse(AscByScore, DescByScore),
    maplist(score_country_flip, DescByScore, Desc).

score_country_flip(Country-Score, Score-Country).

trim_candidates_from_sorted(Sorted, Candidates) :-
    Sorted = [_-MaxScore | _],
    ( MaxScore =< 0.00001 ->
        findall(C, kraj(C), Candidates)
    ; Margin is max(0.0, MaxScore - 0.15),
      findall(C, (member(C-S, Sorted), S >= Margin), CsMargin),
      length(CsMargin, N),
      ( N >= 3 ->
          Candidates = CsMargin
      ; take_first_k_countries(Sorted, 12, Candidates)
      )
    ).

take_first_k_countries([], _, []).
take_first_k_countries(_, 0, []) :- !.
take_first_k_countries([C-_S | Rest], K, [C | Out]) :-
    K > 0,
    K1 is K - 1,
    take_first_k_countries(Rest, K1, Out).

% next_contextual_question(+KnownAnswers, -QuestionId)
% Chooses the best unanswered question using current candidate countries.
next_contextual_question(KnownAnswers, QuestionId) :-
    candidate_countries(KnownAnswers, Candidates),
    Candidates \= [],
    next_question(KnownAnswers, Candidates, QuestionId).
