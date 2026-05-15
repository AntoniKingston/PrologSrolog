% ProGeoLog - szablon bazy wiedzy
% Uzupełniaj symbole konsekwentnie i nie zmieniaj typów danych.

:- module(knowledge_base, [
    kraj/1,
    kraj_ui_label/2,
    pytanie/4,
    cecha_typ/2,
    enum_wartosci/2,
    enum_wartosc/2,
    regula_cf/5,
    regula_fuzzy/5,
    weto/3
]).

% =========================
% 1) Kraje (decyzje)
% =========================
% Aktywne kraje w prototypie (12). Pozostałe — zakomentowane % (nie #).
kraj(argentyna).
kraj(australia).
kraj(brazylia).
kraj(rosja).
kraj(senegal).
kraj(singapur).
kraj(poludniowa_afryka).
kraj(korea_poludniowa).
kraj(sri_lanka).
kraj(zjednoczone_emiraty_arabskie).
kraj(wielka_brytania).
kraj(usa).
% kraj(austria). kraj(bangladesz). kraj(boliwia). kraj(botswana).
% kraj(kambodza). kraj(kanada). kraj(chile). kraj(kolumbia).
% kraj(dominikana). kraj(estonia). kraj(finlandia). kraj(francja).
% kraj(niemcy). kraj(ghana). kraj(gwatemala). kraj(islandia).
% kraj(indie). kraj(indonezja). kraj(izrael). kraj(wlochy).
% kraj(japonia). kraj(kenia). kraj(kirgistan). kraj(lesotho).
% kraj(malezja). kraj(meksyk). kraj(mongolia). kraj(namibia).
% kraj(nowa_zelandia). kraj(nigeria). kraj(norwegia). kraj(oman).
% kraj(panama). kraj(peru). kraj(filipiny). kraj(polska).
% kraj(katar). kraj(rumunia). kraj(rwanda). kraj(hiszpania).
% kraj(szwecja). kraj(szwajcaria). kraj(tajwan). kraj(tajlandia).
% kraj(turcja). kraj(tunezja). kraj(ukraina). kraj(urugwaj).


% Mapa atomu technicznego na etykietę do UI.
kraj_ui_label(albania, 'Albania').
kraj_ui_label(andora, 'Andora').
kraj_ui_label(argentyna, 'Argentyna').
kraj_ui_label(australia, 'Australia').
kraj_ui_label(austria, 'Austria').
kraj_ui_label(bangladesz, 'Bangladesz').
kraj_ui_label(belgia, 'Belgia').
kraj_ui_label(bhutan, 'Bhutan').
kraj_ui_label(boliwia, 'Boliwia').
kraj_ui_label(botswana, 'Botswana').
kraj_ui_label(brazylia, 'Brazylia').
kraj_ui_label(bulgaria, 'Bułgaria').
kraj_ui_label(kambodza, 'Kambodża').
kraj_ui_label(kanada, 'Kanada').
kraj_ui_label(chile, 'Chile').
kraj_ui_label(kolumbia, 'Kolumbia').
kraj_ui_label(chorwacja, 'Chorwacja').
kraj_ui_label(czechy, 'Czechy').
kraj_ui_label(dania, 'Dania').
kraj_ui_label(dominikana, 'Dominikana').
kraj_ui_label(ekwador, 'Ekwador').
kraj_ui_label(estonia, 'Estonia').
kraj_ui_label(eswatini, 'Eswatini').
kraj_ui_label(finlandia, 'Finlandia').
kraj_ui_label(francja, 'Francja').
kraj_ui_label(niemcy, 'Niemcy').
kraj_ui_label(ghana, 'Ghana').
kraj_ui_label(grecja, 'Grecja').
kraj_ui_label(grenlandia, 'Grenlandia').
kraj_ui_label(gwatemala, 'Gwatemala').
kraj_ui_label(wegry, 'Węgry').
kraj_ui_label(islandia, 'Islandia').
kraj_ui_label(indie, 'Indie').
kraj_ui_label(indonezja, 'Indonezja').
kraj_ui_label(irlandia, 'Irlandia').
kraj_ui_label(izrael, 'Izrael').
kraj_ui_label(wlochy, 'Włochy').
kraj_ui_label(japonia, 'Japonia').
kraj_ui_label(jordania, 'Jordania').
kraj_ui_label(kenia, 'Kenia').
kraj_ui_label(kirgistan, 'Kirgistan').
kraj_ui_label(lotwa, 'Łotwa').
kraj_ui_label(liban, 'Liban').
kraj_ui_label(lesotho, 'Lesotho').
kraj_ui_label(liechtenstein, 'Liechtenstein').
kraj_ui_label(litwa, 'Litwa').
kraj_ui_label(luksemburg, 'Luksemburg').
kraj_ui_label(malezja, 'Malezja').
kraj_ui_label(meksyk, 'Meksyk').
kraj_ui_label(mongolia, 'Mongolia').
kraj_ui_label(czarnogora, 'Czarnogóra').
kraj_ui_label(namibia, 'Namibia').
kraj_ui_label(niderlandy, 'Niderlandy').
kraj_ui_label(nowa_zelandia, 'Nowa Zelandia').
kraj_ui_label(nigeria, 'Nigeria').
kraj_ui_label(macedonia_polnocna, 'Macedonia Północna').
kraj_ui_label(norwegia, 'Norwegia').
kraj_ui_label(oman, 'Oman').
kraj_ui_label(palestyna, 'Palestyna').
kraj_ui_label(panama, 'Panama').
kraj_ui_label(peru, 'Peru').
kraj_ui_label(filipiny, 'Filipiny').
kraj_ui_label(polska, 'Polska').
kraj_ui_label(portugalia, 'Portugalia').
kraj_ui_label(katar, 'Katar').
kraj_ui_label(rumunia, 'Rumunia').
kraj_ui_label(rosja, 'Rosja').
kraj_ui_label(rwanda, 'Rwanda').
kraj_ui_label(san_marino, 'San Marino').
kraj_ui_label(wyspy_swietego_tomasza_i_ksiazeca, 'Wyspy Świętego Tomasza i Książęca').
kraj_ui_label(senegal, 'Senegal').
kraj_ui_label(serbia, 'Serbia').
kraj_ui_label(singapur, 'Singapur').
kraj_ui_label(slowacja, 'Słowacja').
kraj_ui_label(slowenia, 'Słowenia').
kraj_ui_label(poludniowa_afryka, 'Południowa Afryka').
kraj_ui_label(korea_poludniowa, 'Korea Południowa').
kraj_ui_label(hiszpania, 'Hiszpania').
kraj_ui_label(sri_lanka, 'Sri Lanka').
kraj_ui_label(szwecja, 'Szwecja').
kraj_ui_label(szwajcaria, 'Szwajcaria').
kraj_ui_label(tajwan, 'Tajwan').
kraj_ui_label(tajlandia, 'Tajlandia').
kraj_ui_label(turcja, 'Turcja').
kraj_ui_label(tunezja, 'Tunezja').
kraj_ui_label(ukraina, 'Ukraina').
kraj_ui_label(uganda, 'Uganda').
kraj_ui_label(zjednoczone_emiraty_arabskie, 'Zjednoczone Emiraty Arabskie').
kraj_ui_label(wielka_brytania, 'Wielka Brytania').
kraj_ui_label(usa, 'Stany Zjednoczone').
kraj_ui_label(urugwaj, 'Urugwaj').
kraj_ui_label(wietnam, 'Wietnam').

% =========================
% 2) Typy cech
% =========================
% cecha_typ(Cecha, Typ).
% Typ: bool | fuzzy | enum
% Zakomentowane: cechy bez odwołań w regułach CF / rozmytych / weto (sekcje 4–6).
%
% --- Ruch i jezdnia ---
cecha_typ(ruch_lewostronny, bool).
cecha_typ(pasy_srodkowe_zolte, bool).
% nieużywane w sekcjach 4–6
%cecha_typ(linia_krawedziowa_biala, bool).
cecha_typ(droga_szeroka, fuzzy).
cecha_typ(jakosc_nawierzchni, fuzzy).
% nieużywane w sekcjach 4–6
%cecha_typ(typ_linii_jezdni, enum).
cecha_typ(typ_znaku_ograniczenia_predkosci, enum).
%
% --- Słupki, znaki i infrastruktura ---
% nieużywane w sekcjach 4–6
%cecha_typ(typ_slupka, enum).
cecha_typ(slupek_bialo_czerwony_aus, bool).
cecha_typ(znak_speed_limit_usa, bool).
cecha_typ(znak_ostrzegawczy_zolty_rombowy, bool).
% nieużywane w sekcjach 4–6
%cecha_typ(znak_nakazu_okragly, bool).
cecha_typ(typ_barierek_drogowych, enum).
% nieużywane w sekcjach 4–6
%cecha_typ(typ_latarni_ulicznych, enum).
%
% --- Tablice i pojazdy ---
cecha_typ(tablica_zolte_tyl, bool).
cecha_typ(tablica_dluga_eu, bool).
% nieużywane w sekcjach 4–6
%cecha_typ(tablica_krotka_przod, bool).
cecha_typ(kolor_tylnej_tablicy, enum).
cecha_typ(format_tablicy_rejestracyjnej, enum).
cecha_typ(obecnosc_motocykli, fuzzy).
%
% --- Język i pismo ---
cecha_typ(alfabet_dominujacy, enum).
cecha_typ(jezyk_na_znakach, enum).
cecha_typ(cyrylica_obecna, bool).
cecha_typ(hangul_obecny, bool).
cecha_typ(kanji_obecne, bool).
cecha_typ(arabski_obecny, bool).
% nieużywane w sekcjach 4–6
%cecha_typ(dlugosc_napisow, fuzzy).
%
% --- Środowisko i klimat ---
cecha_typ(gorzystosc_terenu, fuzzy).
cecha_typ(wysokosc_roslinnosci, fuzzy).
cecha_typ(zageszczenie_lasu, fuzzy).
cecha_typ(suchosc_klimatu, fuzzy).
cecha_typ(wilgotnosc_klimatu, fuzzy).
cecha_typ(zachmurzenie, fuzzy).
cecha_typ(typ_biomu, enum).
cecha_typ(obecnosc_palm, bool).
% nieużywane w sekcjach 4–6
%cecha_typ(obecnosc_iglastego_lasu, bool).
%
% --- Zabudowa i urbanistyka ---
cecha_typ(styl_architektury, enum).
cecha_typ(gestosc_zabudowy, fuzzy).
cecha_typ(wysokosc_budynkow, fuzzy).
cecha_typ(typ_dachow, enum).
cecha_typ(kolorystyka_budynkow, enum).
cecha_typ(obecnosc_blokow_mieszkalnych, bool).
cecha_typ(obecnosc_domow_jednorodzinnych, bool).
%
% --- Geografia i otoczenie ---
cecha_typ(dostep_do_morza_widoczny, bool).
cecha_typ(obecnosc_gor_ostrych, bool).
cecha_typ(obecnosc_rownin, bool).
cecha_typ(obecnosc_pustyni, bool).
cecha_typ(obecnosc_sniegu, bool).
%
% --- Meta Street View ---
cecha_typ(generacja_kamery_google, enum).
% nieużywane w sekcjach 4–6
%cecha_typ(poziom_bluru, fuzzy).
cecha_typ(polozenie_kamery_nad_ziemia, fuzzy).
% nieużywane w sekcjach 4–6
%cecha_typ(artefakty_laczenia_panorama, bool).

% =========================
% 3) Pytania dialogowe
% =========================
% pytanie(Id, Cecha, FormaOdpowiedzi, KontekstTag).
% FormaOdpowiedzi: radio | checkbox | slider | enum
% KontekstTag używaj do reguł kontekstowych wyboru pytania.
% Zakomentowane: pytania i enum_wartosci/2 dla cech nieużywanych w sekcjach 4–6.
%
% --- Ruch i jezdnia ---
pytanie(q_ruch_lewostronny, ruch_lewostronny, radio, transport).
pytanie(q_pasy_srodkowe_zolte, pasy_srodkowe_zolte, radio, transport).
% nieużywane w sekcjach 4–6
%pytanie(q_linia_krawedziowa_biala, linia_krawedziowa_biala, radio, transport).
pytanie(q_droga_szeroka, droga_szeroka, slider, transport).
pytanie(q_jakosc_nawierzchni, jakosc_nawierzchni, slider, transport).
% nieużywane w sekcjach 4–6
%pytanie(q_typ_linii_jezdni, typ_linii_jezdni, enum, transport).
pytanie(q_typ_znaku_ograniczenia_predkosci, typ_znaku_ograniczenia_predkosci, enum, transport).
%
% --- Słupki, znaki i infrastruktura ---
% nieużywane w sekcjach 4–6
%pytanie(q_typ_slupka, typ_slupka, enum, infrastruktura).
pytanie(q_slupek_bialo_czerwony_aus, slupek_bialo_czerwony_aus, radio, infrastruktura).
pytanie(q_znak_speed_limit_usa, znak_speed_limit_usa, radio, infrastruktura).
pytanie(q_znak_ostrzegawczy_zolty_rombowy, znak_ostrzegawczy_zolty_rombowy, radio, infrastruktura).
% nieużywane w sekcjach 4–6
%pytanie(q_znak_nakazu_okragly, znak_nakazu_okragly, radio, infrastruktura).
pytanie(q_typ_barierek_drogowych, typ_barierek_drogowych, enum, infrastruktura).
% nieużywane w sekcjach 4–6
%pytanie(q_typ_latarni_ulicznych, typ_latarni_ulicznych, enum, infrastruktura).
%
% --- Tablice i pojazdy ---
pytanie(q_tablica_zolte_tyl, tablica_zolte_tyl, radio, tablice).
pytanie(q_tablica_dluga_eu, tablica_dluga_eu, radio, tablice).
% nieużywane w sekcjach 4–6
%pytanie(q_tablica_krotka_przod, tablica_krotka_przod, radio, tablice).
pytanie(q_kolor_tylnej_tablicy, kolor_tylnej_tablicy, enum, tablice).
pytanie(q_format_tablicy_rejestracyjnej, format_tablicy_rejestracyjnej, enum, tablice).
pytanie(q_obecnosc_motocykli, obecnosc_motocykli, slider, tablice).
%
% --- Język i pismo ---
pytanie(q_alfabet_dominujacy, alfabet_dominujacy, enum, jezyk).
pytanie(q_jezyk_na_znakach, jezyk_na_znakach, enum, jezyk).
pytanie(q_cyrylica_obecna, cyrylica_obecna, radio, jezyk).
pytanie(q_hangul_obecny, hangul_obecny, radio, jezyk).
pytanie(q_kanji_obecne, kanji_obecne, radio, jezyk).
pytanie(q_arabski_obecny, arabski_obecny, radio, jezyk).
% nieużywane w sekcjach 4–6
%pytanie(q_dlugosc_napisow, dlugosc_napisow, slider, jezyk).
%
% --- Środowisko i klimat ---
pytanie(q_gorzystosc_terenu, gorzystosc_terenu, slider, srodowisko).
pytanie(q_wysokosc_roslinnosci, wysokosc_roslinnosci, slider, srodowisko).
pytanie(q_zageszczenie_lasu, zageszczenie_lasu, slider, srodowisko).
pytanie(q_suchosc_klimatu, suchosc_klimatu, slider, srodowisko).
pytanie(q_wilgotnosc_klimatu, wilgotnosc_klimatu, slider, srodowisko).
pytanie(q_zachmurzenie, zachmurzenie, slider, srodowisko).
pytanie(q_typ_biomu, typ_biomu, enum, srodowisko).
pytanie(q_obecnosc_palm, obecnosc_palm, radio, srodowisko).
% nieużywane w sekcjach 4–6
%pytanie(q_obecnosc_iglastego_lasu, obecnosc_iglastego_lasu, radio, srodowisko).
%
% --- Zabudowa i urbanistyka ---
pytanie(q_styl_architektury, styl_architektury, enum, zabudowa).
pytanie(q_gestosc_zabudowy, gestosc_zabudowy, slider, zabudowa).
pytanie(q_wysokosc_budynkow, wysokosc_budynkow, slider, zabudowa).
pytanie(q_typ_dachow, typ_dachow, enum, zabudowa).
pytanie(q_kolorystyka_budynkow, kolorystyka_budynkow, enum, zabudowa).
pytanie(q_obecnosc_blokow_mieszkalnych, obecnosc_blokow_mieszkalnych, radio, zabudowa).
pytanie(q_obecnosc_domow_jednorodzinnych, obecnosc_domow_jednorodzinnych, radio, zabudowa).
%
% --- Geografia i otoczenie ---
pytanie(q_dostep_do_morza_widoczny, dostep_do_morza_widoczny, radio, geografia).
pytanie(q_obecnosc_gor_ostrych, obecnosc_gor_ostrych, radio, geografia).
pytanie(q_obecnosc_rownin, obecnosc_rownin, radio, geografia).
pytanie(q_obecnosc_pustyni, obecnosc_pustyni, radio, geografia).
pytanie(q_obecnosc_sniegu, obecnosc_sniegu, radio, geografia).
%
% --- Meta Street View ---
pytanie(q_generacja_kamery_google, generacja_kamery_google, enum, meta).
% nieużywane w sekcjach 4–6
%pytanie(q_poziom_bluru, poziom_bluru, slider, meta).
pytanie(q_polozenie_kamery_nad_ziemia, polozenie_kamery_nad_ziemia, slider, meta).
% nieużywane w sekcjach 4–6
%pytanie(q_artefakty_laczenia_panorama, artefakty_laczenia_panorama, radio, meta).

% --- Wartości cech typu enum (szablon) ---
% enum_wartosci(Cecha, ListaWartosci).
% nieużywane w sekcjach 4–6
%enum_wartosci(typ_linii_jezdni, [ciagla, przerywana, podwojna_ciagla, mieszana]).
enum_wartosci(typ_znaku_ograniczenia_predkosci, [okragly_eu, prostokatny_usa, brak_rozpoznania]).
% nieużywane w sekcjach 4–6
%enum_wartosci(typ_slupka, [bialo_czerwony, betonowy, metalowy, drewniany, brak_charakterystycznego]).
enum_wartosci(typ_barierek_drogowych, [metalowe_faliste, betonowe, linowe, brak]).
% nieużywane w sekcjach 4–6
%enum_wartosci(typ_latarni_ulicznych, [wysokie_nowoczesne, niskie_klasyczne, brak]).
enum_wartosci(kolor_tylnej_tablicy, [bialy, zolty, czerwony, czarny, inny]).
enum_wartosci(format_tablicy_rejestracyjnej, [dluga_eu, krotka_usa, kwadratowa, niestandardowa]).
enum_wartosci(alfabet_dominujacy, [lacinski, cyrylica, arabski, han, hangul, mieszany]).
enum_wartosci(jezyk_na_znakach, [angielski, hiszpanski, francuski, niemiecki, arabski, rosyjski, japonski, koreanski, inny]).
enum_wartosci(typ_biomu, [umiarkowany, tropikalny, pustynny, borealny, wysokogorski, srodziemnomorski]).
enum_wartosci(styl_architektury, [skandynawski, kolonialny, modernistyczny, srodziemnomorski, postsowiecki, azjatycki, mieszany]).
enum_wartosci(typ_dachow, [dwuspadowy, plaski, blaszany, dachowka_ceramiczna, mieszany]).
enum_wartosci(kolorystyka_budynkow, [jasna, ceglana, pastelowa, szara, kontrastowa]).
enum_wartosci(generacja_kamery_google, [gen2, gen3, gen4, nieznana]).

% Pojedyncze wartości enum (do UI / zapytań iteracyjnych)
enum_wartosc(Cecha, W) :-
    enum_wartosci(Cecha, Lista),
    member(W, Lista).

% =========================
% 4) Reguły przybliżone (CF)
% =========================
% regula_cf(IdReguly, Kraj, Przeslanki, Waga, Priorytet).
% Przeslanki to lista literałów:
%   cecha(C, tak)
%   cecha(C, nie)
%   cecha_enum(C, Wartosc)
%   cecha_num(C, Min, Max)


% Pakiet 100 reguł CF — 12 aktywnych krajów (8–9 reguł na kraj).

% --- Argentyna (8): r001–r008 ---
regula_cf(r_cf_001, argentyna,
    [cecha_enum(jezyk_na_znakach, hiszpanski), cecha(ruch_lewostronny, no)],
    0.88, 10).
regula_cf(r_cf_002, argentyna,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(alfabet_dominujacy, lacinski)],
    0.72, 8).
regula_cf(r_cf_003, argentyna,
    [cecha(obecnosc_rownin, yes), cecha_enum(typ_biomu, umiarkowany)],
    0.65, 7).
regula_cf(r_cf_004, argentyna,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha(ruch_lewostronny, no)],
    0.58, 7).
regula_cf(r_cf_005, argentyna,
    [cecha_enum(kolorystyka_budynkow, pastelowa), cecha_enum(typ_biomu, tropikalny)],
    0.52, 6).
regula_cf(r_cf_006, argentyna,
    [cecha_enum(jezyk_na_znakach, inny), cecha(obecnosc_palm, no)],
    0.48, 5).
regula_cf(r_cf_007, argentyna,
    [cecha_num(suchosc_klimatu, 40, 75), cecha_enum(styl_architektury, mieszany)],
    0.45, 5).
regula_cf(r_cf_008, argentyna,
    [cecha_enum(typ_znaku_ograniczenia_predkosci, okragly_eu), cecha(obecnosc_domow_jednorodzinnych, yes)],
    0.42, 5).

% --- Australia (9): r009–r017 ---
regula_cf(r_cf_009, australia,
    [cecha(ruch_lewostronny, yes), cecha(slupek_bialo_czerwony_aus, yes)],
    0.92, 10).
regula_cf(r_cf_010, australia,
    [cecha_enum(typ_biomu, pustynny), cecha(obecnosc_palm, no)],
    0.78, 9).
regula_cf(r_cf_011, australia,
    [cecha_enum(jezyk_na_znakach, angielski), cecha(ruch_lewostronny, yes)],
    0.75, 8).
regula_cf(r_cf_012, australia,
    [cecha_num(suchosc_klimatu, 65, 100), cecha_enum(typ_biomu, pustynny)],
    0.72, 8).
regula_cf(r_cf_013, australia,
    [cecha_enum(kolor_tylnej_tablicy, bialy), cecha_enum(generacja_kamery_google, gen4)],
    0.55, 7).
regula_cf(r_cf_014, australia,
    [cecha_enum(typ_znaku_ograniczenia_predkosci, okragly_eu), cecha(tablica_dluga_eu, yes)],
    0.50, 6).
regula_cf(r_cf_015, australia,
    [cecha(obecnosc_pustyni, yes), cecha_num(zachmurzenie, 20, 60)],
    0.62, 7).
regula_cf(r_cf_016, australia,
    [cecha_enum(alfabet_dominujacy, lacinski), cecha(obecnosc_sniegu, no)],
    0.48, 5).
regula_cf(r_cf_017, australia,
    [cecha_enum(styl_architektury, kolonialny), cecha(dostep_do_morza_widoczny, yes)],
    0.44, 5).

% --- Brazylia (8): r018–r025 ---
regula_cf(r_cf_018, brazylia,
    [cecha_enum(typ_biomu, tropikalny), cecha_num(wilgotnosc_klimatu, 60, 100)],
    0.85, 10).
regula_cf(r_cf_019, brazylia,
    [cecha_enum(jezyk_na_znakach, inny), cecha(obecnosc_palm, yes)],
    0.78, 9).
regula_cf(r_cf_020, brazylia,
    [cecha(ruch_lewostronny, no), cecha_enum(kolorystyka_budynkow, pastelowa)],
    0.70, 8).
regula_cf(r_cf_021, brazylia,
    [cecha_num(obecnosc_motocykli, 50, 100), cecha(obecnosc_domow_jednorodzinnych, yes)],
    0.58, 7).
regula_cf(r_cf_022, brazylia,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(alfabet_dominujacy, lacinski)],
    0.52, 6).
regula_cf(r_cf_023, brazylia,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(typ_biomu, tropikalny)],
    0.55, 7).
regula_cf(r_cf_024, brazylia,
    [cecha_enum(jezyk_na_znakach, hiszpanski), cecha(ruch_lewostronny, no)],
    0.48, 5).
regula_cf(r_cf_025, brazylia,
    [cecha(obecnosc_gor_ostrych, no), cecha_num(gestosc_zabudowy, 40, 80)],
    0.42, 5).

% --- Rosja (8): r026–r033 ---
regula_cf(r_cf_026, rosja,
    [cecha_enum(jezyk_na_znakach, rosyjski), cecha_enum(styl_architektury, postsowiecki)],
    0.92, 10).
regula_cf(r_cf_027, rosja,
    [cecha(cyrylica_obecna, yes), cecha_enum(alfabet_dominujacy, cyrylica)],
    0.88, 10).
regula_cf(r_cf_028, rosja,
    [cecha_enum(jezyk_na_znakach, rosyjski), cecha(ruch_lewostronny, no)],
    0.72, 8).
regula_cf(r_cf_029, rosja,
    [cecha_enum(typ_biomu, borealny), cecha(obecnosc_sniegu, yes)],
    0.68, 8).
regula_cf(r_cf_030, rosja,
    [cecha_enum(typ_biomu, srodziemnomorski), cecha_enum(jezyk_na_znakach, rosyjski)],
    0.62, 7).
regula_cf(r_cf_031, rosja,
    [cecha_enum(generacja_kamery_google, gen3), cecha_enum(styl_architektury, postsowiecki)],
    0.55, 7).
regula_cf(r_cf_032, rosja,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha(cyrylica_obecna, yes)],
    0.50, 6).
regula_cf(r_cf_033, rosja,
    [cecha_num(zachmurzenie, 50, 100), cecha_enum(kolorystyka_budynkow, szara)],
    0.45, 5).

% --- Senegal (8): r034–r041 ---
regula_cf(r_cf_034, senegal,
    [cecha_enum(jezyk_na_znakach, francuski), cecha_enum(typ_biomu, tropikalny)],
    0.86, 10).
regula_cf(r_cf_035, senegal,
    [cecha_num(suchosc_klimatu, 55, 90), cecha(obecnosc_pustyni, no)],
    0.75, 8).
regula_cf(r_cf_036, senegal,
    [cecha_enum(styl_architektury, kolonialny), cecha(ruch_lewostronny, no)],
    0.70, 8).
regula_cf(r_cf_037, senegal,
    [cecha(obecnosc_palm, yes), cecha_enum(typ_biomu, tropikalny)],
    0.68, 7).
regula_cf(r_cf_038, senegal,
    [cecha_enum(alfabet_dominujacy, lacinski), cecha_enum(jezyk_na_znakach, francuski)],
    0.62, 7).
regula_cf(r_cf_039, senegal,
    [cecha_enum(kolorystyka_budynkow, pastelowa), cecha(dostep_do_morza_widoczny, yes)],
    0.58, 6).
regula_cf(r_cf_040, senegal,
    [cecha(arabski_obecny, no), cecha_enum(jezyk_na_znakach, francuski)],
    0.48, 5).
regula_cf(r_cf_041, senegal,
    [cecha_num(wilgotnosc_klimatu, 50, 85), cecha_enum(styl_architektury, mieszany)],
    0.45, 5).

% --- Singapur (8): r042–r049 ---
regula_cf(r_cf_042, singapur,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(styl_architektury, modernistyczny)],
    0.90, 10).
regula_cf(r_cf_043, singapur,
    [cecha(ruch_lewostronny, no), cecha_num(gestosc_zabudowy, 75, 100)],
    0.85, 9).
regula_cf(r_cf_044, singapur,
    [cecha_enum(typ_biomu, tropikalny), cecha_num(wilgotnosc_klimatu, 70, 100)],
    0.78, 8).
regula_cf(r_cf_045, singapur,
    [cecha_enum(styl_architektury, azjatycki), cecha(obecnosc_blokow_mieszkalnych, yes)],
    0.72, 8).
regula_cf(r_cf_046, singapur,
    [cecha(hangul_obecny, no), cecha(kanji_obecne, no)],
    0.65, 7).
regula_cf(r_cf_047, singapur,
    [cecha_enum(generacja_kamery_google, gen4), cecha_num(wysokosc_budynkow, 60, 100)],
    0.60, 7).
regula_cf(r_cf_048, singapur,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha(ruch_lewostronny, no)],
    0.52, 6).
regula_cf(r_cf_049, singapur,
    [cecha_enum(kolorystyka_budynkow, jasna), cecha(dostep_do_morza_widoczny, yes)],
    0.50, 6).

% --- Południowa Afryka (8): r050–r057 ---
regula_cf(r_cf_050, poludniowa_afryka,
    [cecha(ruch_lewostronny, yes), cecha_enum(jezyk_na_znakach, angielski)],
    0.90, 10).
regula_cf(r_cf_051, poludniowa_afryka,
    [cecha(tablica_zolte_tyl, yes), cecha(ruch_lewostronny, yes)],
    0.82, 9).
regula_cf(r_cf_052, poludniowa_afryka,
    [cecha_enum(typ_biomu, umiarkowany), cecha_enum(styl_architektury, kolonialny)],
    0.70, 8).
regula_cf(r_cf_053, poludniowa_afryka,
    [cecha_enum(alfabet_dominujacy, lacinski), cecha_enum(jezyk_na_znakach, angielski)],
    0.65, 7).
regula_cf(r_cf_054, poludniowa_afryka,
    [cecha(obecnosc_gor_ostrych, yes), cecha(dostep_do_morza_widoczny, yes)],
    0.62, 7).
regula_cf(r_cf_055, poludniowa_afryka,
    [cecha_enum(kolor_tylnej_tablicy, zolty), cecha(tablica_dluga_eu, yes)],
    0.58, 6).
regula_cf(r_cf_056, poludniowa_afryka,
    [cecha_num(suchosc_klimatu, 35, 70), cecha(obecnosc_palm, no)],
    0.52, 6).
regula_cf(r_cf_057, poludniowa_afryka,
    [cecha_enum(typ_biomu, srodziemnomorski), cecha_num(zachmurzenie, 30, 70)],
    0.48, 5).

% --- Korea Południowa (9): r058–r066 ---
regula_cf(r_cf_058, korea_poludniowa,
    [cecha(hangul_obecny, yes), cecha(ruch_lewostronny, no)],
    0.94, 10).
regula_cf(r_cf_059, korea_poludniowa,
    [cecha_enum(alfabet_dominujacy, hangul), cecha_enum(jezyk_na_znakach, koreanski)],
    0.90, 10).
regula_cf(r_cf_060, korea_poludniowa,
    [cecha_enum(styl_architektury, azjatycki), cecha_num(gestosc_zabudowy, 60, 100)],
    0.78, 8).
regula_cf(r_cf_061, korea_poludniowa,
    [cecha_enum(jezyk_na_znakach, koreanski), cecha_enum(typ_dachow, plaski)],
    0.74, 8).
regula_cf(r_cf_062, korea_poludniowa,
    [cecha(obecnosc_blokow_mieszkalnych, yes), cecha_enum(styl_architektury, azjatycki)],
    0.68, 7).
regula_cf(r_cf_063, korea_poludniowa,
    [cecha_enum(generacja_kamery_google, gen4), cecha_num(polozenie_kamery_nad_ziemia, 40, 70)],
    0.55, 7).
regula_cf(r_cf_064, korea_poludniowa,
    [cecha(kanji_obecne, no), cecha(cyrylica_obecna, no)],
    0.60, 6).
regula_cf(r_cf_065, korea_poludniowa,
    [cecha_enum(typ_biomu, umiarkowany), cecha(obecnosc_sniegu, yes)],
    0.52, 6).
regula_cf(r_cf_066, korea_poludniowa,
    [cecha_enum(kolorystyka_budynkow, szara), cecha(ruch_lewostronny, no)],
    0.45, 5).

% --- Sri Lanka (8): r067–r074 ---
regula_cf(r_cf_067, sri_lanka,
    [cecha(ruch_lewostronny, yes), cecha_enum(jezyk_na_znakach, angielski)],
    0.88, 10).
regula_cf(r_cf_068, sri_lanka,
    [cecha_enum(typ_biomu, tropikalny), cecha(obecnosc_palm, yes)],
    0.82, 9).
regula_cf(r_cf_069, sri_lanka,
    [cecha_enum(styl_architektury, kolonialny), cecha(ruch_lewostronny, yes)],
    0.75, 8).
regula_cf(r_cf_070, sri_lanka,
    [cecha_num(wilgotnosc_klimatu, 65, 100), cecha_enum(typ_biomu, tropikalny)],
    0.72, 8).
regula_cf(r_cf_071, sri_lanka,
    [cecha_enum(styl_architektury, azjatycki), cecha(obecnosc_gor_ostrych, yes)],
    0.58, 6).
regula_cf(r_cf_072, sri_lanka,
    [cecha(tablica_dluga_eu, yes), cecha_enum(kolor_tylnej_tablicy, zolty)],
    0.55, 7).
regula_cf(r_cf_073, sri_lanka,
    [cecha(hangul_obecny, no), cecha(arabski_obecny, no)],
    0.50, 6).
regula_cf(r_cf_074, sri_lanka,
    [cecha_enum(alfabet_dominujacy, lacinski), cecha(dostep_do_morza_widoczny, yes)],
    0.48, 5).

% --- Zjednoczone Emiraty Arabskie (9): r075–r083 ---
regula_cf(r_cf_075, zjednoczone_emiraty_arabskie,
    [cecha(arabski_obecny, yes), cecha_enum(typ_biomu, pustynny)],
    0.93, 10).
regula_cf(r_cf_076, zjednoczone_emiraty_arabskie,
    [cecha_num(suchosc_klimatu, 75, 100), cecha(obecnosc_pustyni, yes)],
    0.90, 10).
regula_cf(r_cf_077, zjednoczone_emiraty_arabskie,
    [cecha_enum(jezyk_na_znakach, arabski), cecha_enum(alfabet_dominujacy, arabski)],
    0.85, 9).
regula_cf(r_cf_078, zjednoczone_emiraty_arabskie,
    [cecha_enum(styl_architektury, modernistyczny), cecha_num(wysokosc_budynkow, 70, 100)],
    0.78, 8).
regula_cf(r_cf_079, zjednoczone_emiraty_arabskie,
    [cecha_enum(jezyk_na_znakach, arabski), cecha(dostep_do_morza_widoczny, yes)],
    0.72, 8).
regula_cf(r_cf_080, zjednoczone_emiraty_arabskie,
    [cecha_enum(generacja_kamery_google, gen4), cecha_enum(kolorystyka_budynkow, jasna)],
    0.55, 7).
regula_cf(r_cf_081, zjednoczone_emiraty_arabskie,
    [cecha(ruch_lewostronny, no), cecha(obecnosc_sniegu, no)],
    0.62, 7).
regula_cf(r_cf_082, zjednoczone_emiraty_arabskie,
    [cecha_enum(typ_biomu, pustynny), cecha(obecnosc_palm, yes)],
    0.58, 6).
regula_cf(r_cf_083, zjednoczone_emiraty_arabskie,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha(arabski_obecny, yes)],
    0.48, 5).

% --- Wielka Brytania (9): r084–r092 ---
regula_cf(r_cf_084, wielka_brytania,
    [cecha(ruch_lewostronny, yes), cecha(tablica_zolte_tyl, yes)],
    0.94, 10).
regula_cf(r_cf_085, wielka_brytania,
    [cecha(tablica_dluga_eu, yes), cecha_enum(jezyk_na_znakach, angielski)],
    0.82, 9).
regula_cf(r_cf_086, wielka_brytania,
    [cecha_enum(kolor_tylnej_tablicy, zolty), cecha(ruch_lewostronny, yes)],
    0.88, 9).
regula_cf(r_cf_087, wielka_brytania,
    [cecha_enum(typ_biomu, umiarkowany), cecha_num(zachmurzenie, 50, 100)],
    0.65, 7).
regula_cf(r_cf_088, wielka_brytania,
    [cecha_enum(styl_architektury, kolonialny), cecha(obecnosc_blokow_mieszkalnych, no)],
    0.55, 6).
regula_cf(r_cf_089, wielka_brytania,
    [cecha_enum(typ_znaku_ograniczenia_predkosci, okragly_eu), cecha(ruch_lewostronny, yes)],
    0.60, 7).
regula_cf(r_cf_090, wielka_brytania,
    [cecha_enum(alfabet_dominujacy, lacinski), cecha_enum(jezyk_na_znakach, angielski)],
    0.52, 6).
regula_cf(r_cf_091, wielka_brytania,
    [cecha(obecnosc_sniegu, no), cecha_num(suchosc_klimatu, 20, 55)],
    0.48, 5).
regula_cf(r_cf_092, wielka_brytania,
    [cecha_enum(styl_architektury, skandynawski), cecha_enum(typ_dachow, dwuspadowy)],
    0.40, 4).

% --- USA (8): r093–r100 ---
regula_cf(r_cf_093, usa,
    [cecha(ruch_lewostronny, no), cecha(znak_speed_limit_usa, yes)],
    0.94, 10).
regula_cf(r_cf_094, usa,
    [cecha_enum(format_tablicy_rejestracyjnej, krotka_usa), cecha_enum(alfabet_dominujacy, lacinski)],
    0.85, 9).
regula_cf(r_cf_095, usa,
    [cecha(pasy_srodkowe_zolte, yes), cecha_enum(typ_znaku_ograniczenia_predkosci, prostokatny_usa)],
    0.88, 9).
regula_cf(r_cf_096, usa,
    [cecha_enum(jezyk_na_znakach, angielski), cecha(tablica_dluga_eu, no)],
    0.72, 8).
regula_cf(r_cf_097, usa,
    [cecha_enum(typ_barierek_drogowych, metalowe_faliste), cecha(obecnosc_domow_jednorodzinnych, yes)],
    0.65, 7).
regula_cf(r_cf_098, usa,
    [cecha_enum(typ_biomu, umiarkowany), cecha(ruch_lewostronny, no)],
    0.58, 6).
regula_cf(r_cf_099, usa,
    [cecha(znak_ostrzegawczy_zolty_rombowy, yes), cecha(ruch_lewostronny, no)],
    0.62, 7).
regula_cf(r_cf_100, usa,
    [cecha_enum(generacja_kamery_google, gen4), cecha_num(suchosc_klimatu, 30, 65)],
    0.45, 5).

% =========================
% 5) Reguły rozmyte (30 — 2–3 na kraj aktywny)
% =========================
% regula_fuzzy(IdReguly, Kraj, Zmienna, EtykietaLingwistyczna, Waga).
% Etykiety w inference_engine.pl: plaski (niskie X), pagorkowaty (środek), gorzysty (wysokie X).

% --- Argentyna (2) ---
regula_fuzzy(r_fz_001, argentyna, suchosc_klimatu, pagorkowaty, 0.50).
regula_fuzzy(r_fz_002, argentyna, gestosc_zabudowy, pagorkowaty, 0.45).

% --- Australia (3) ---
regula_fuzzy(r_fz_003, australia, gorzystosc_terenu, plaski, 0.65).
regula_fuzzy(r_fz_004, australia, suchosc_klimatu, gorzysty, 0.70).
regula_fuzzy(r_fz_005, australia, wysokosc_roslinnosci, plaski, 0.55).

% --- Brazylia (3) ---
regula_fuzzy(r_fz_006, brazylia, wilgotnosc_klimatu, gorzysty, 0.72).
regula_fuzzy(r_fz_007, brazylia, obecnosc_motocykli, gorzysty, 0.58).
regula_fuzzy(r_fz_008, brazylia, gorzystosc_terenu, plaski, 0.48).

% --- Rosja (3) ---
regula_fuzzy(r_fz_009, rosja, zachmurzenie, gorzysty, 0.55).
regula_fuzzy(r_fz_010, rosja, wysokosc_roslinnosci, pagorkowaty, 0.50).
regula_fuzzy(r_fz_011, rosja, gorzystosc_terenu, pagorkowaty, 0.48).

% --- Senegal (2) ---
regula_fuzzy(r_fz_012, senegal, suchosc_klimatu, gorzysty, 0.62).
regula_fuzzy(r_fz_013, senegal, wilgotnosc_klimatu, pagorkowaty, 0.52).

% --- Singapur (2) ---
regula_fuzzy(r_fz_014, singapur, gestosc_zabudowy, gorzysty, 0.75).
regula_fuzzy(r_fz_015, singapur, wysokosc_budynkow, gorzysty, 0.68).

% --- Południowa Afryka (2) ---
regula_fuzzy(r_fz_016, poludniowa_afryka, suchosc_klimatu, pagorkowaty, 0.55).
regula_fuzzy(r_fz_017, poludniowa_afryka, gestosc_zabudowy, pagorkowaty, 0.48).

% --- Korea Południowa (2) ---
regula_fuzzy(r_fz_018, korea_poludniowa, gestosc_zabudowy, gorzysty, 0.70).
regula_fuzzy(r_fz_019, korea_poludniowa, wysokosc_budynkow, gorzysty, 0.65).

% --- Sri Lanka (2) ---
regula_fuzzy(r_fz_020, sri_lanka, wilgotnosc_klimatu, gorzysty, 0.70).
regula_fuzzy(r_fz_021, sri_lanka, wysokosc_roslinnosci, gorzysty, 0.58).

% --- Zjednoczone Emiraty Arabskie (3) ---
regula_fuzzy(r_fz_022, zjednoczone_emiraty_arabskie, suchosc_klimatu, gorzysty, 0.78).
regula_fuzzy(r_fz_023, zjednoczone_emiraty_arabskie, gorzystosc_terenu, plaski, 0.62).
regula_fuzzy(r_fz_024, zjednoczone_emiraty_arabskie, wysokosc_budynkow, gorzysty, 0.60).

% --- Wielka Brytania (3) ---
regula_fuzzy(r_fz_025, wielka_brytania, zachmurzenie, gorzysty, 0.60).
regula_fuzzy(r_fz_026, wielka_brytania, wilgotnosc_klimatu, gorzysty, 0.55).
regula_fuzzy(r_fz_027, wielka_brytania, zageszczenie_lasu, pagorkowaty, 0.45).

% --- USA (3) ---
regula_fuzzy(r_fz_028, usa, droga_szeroka, gorzysty, 0.58).
regula_fuzzy(r_fz_029, usa, jakosc_nawierzchni, pagorkowaty, 0.50).
regula_fuzzy(r_fz_030, usa, suchosc_klimatu, plaski, 0.52).

% =========================
% 6) Weta (warunki wykluczające) — min. 1 na aktywny kraj
% =========================
% weto(Kraj, Warunek, Prog).
% cecha(F, no/nie): kara gdy użytkownik odpowie yes (np. ruch lewostronny przy krajach jadących prawą).
% cecha(F, yes/tak): kara gdy użytkownik odpowie no.
% cecha_enum(F, W): kara gdy odpowiedź enum jest inna niż W.

% --- Argentyna ---
weto(argentyna, cecha(hangul_obecny, no), 0.75).

% --- Australia ---
weto(australia, cecha(tablica_zolte_tyl, no), 0.80).
weto(australia, cecha(znak_speed_limit_usa, no), 0.75).

% --- Brazylia ---
weto(brazylia, cecha_enum(typ_biomu, borealny), 0.80).

% --- Rosja ---
weto(rosja, cecha(kanji_obecne, no), 0.75).

% --- Senegal ---
weto(senegal, cecha(cyrylica_obecna, no), 0.75).

% --- Singapur ---
weto(singapur, cecha(ruch_lewostronny, yes), 0.75).

% --- Południowa Afryka ---
weto(poludniowa_afryka, cecha(znak_speed_limit_usa, no), 0.80).

% --- Korea Południowa ---
weto(korea_poludniowa, cecha(hangul_obecny, yes), 0.80).

% --- Sri Lanka ---
weto(sri_lanka, cecha(ruch_lewostronny, yes), 0.75).

% --- Zjednoczone Emiraty Arabskie ---
weto(zjednoczone_emiraty_arabskie, cecha(obecnosc_sniegu, no), 0.75).

% --- Wielka Brytania ---
weto(wielka_brytania, cecha(znak_speed_limit_usa, no), 0.80).

% --- USA ---
weto(usa, cecha(ruch_lewostronny, no), 0.70).
weto(usa, cecha(tablica_zolte_tyl, yes), 0.75).

% =========================
% 7) Instrukcja ręcznego uzupełniania
% =========================
% [KROK 1] Dodaj wszystkie kraje przez kraj/1.
% [KROK 2] Ustal słownik cech przez cecha_typ/2.
% [KROK 3] Dla każdej cechy dodaj pytanie w pytanie/4 i (dla enum) enum_wartosci/2.
% [KROK 4] Dodaj minimum 100 reguł produkcji:
%          - regula_cf/5 + regula_fuzzy/5 + reguły kontekstowe (w innym module).
% [KROK 5] Dodaj weto/3 wyłącznie dla mocnych konfliktów.
% [KROK 6] Zachowuj spójność symboli między UI i Prologiem.

