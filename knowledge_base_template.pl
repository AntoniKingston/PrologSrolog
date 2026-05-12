% ProGeoLog - szablon bazy wiedzy
% Uzupełniaj symbole konsekwentnie i nie zmieniaj typów danych.

:- module(knowledge_base, [
    kraj/1,
    kraj_ui_label/2,
    pytanie/4,
    cecha_typ/2,
    enum_wartosci/2,
    regula_cf/5,
    regula_fuzzy/5,
    weto/3
]).

% =========================
% 1) Kraje (decyzje)
% =========================
% Dodaj wszystkie rozważane kraje.
kraj(albania).
kraj(andora).
kraj(argentyna).
kraj(australia).
kraj(austria).
kraj(bangladesz).
kraj(belgia).
kraj(bhutan).
kraj(boliwia).
kraj(botswana).
kraj(brazylia).
kraj(bulgaria).
kraj(kambodza).
kraj(kanada).
kraj(chile).
kraj(kolumbia).
kraj(chorwacja).
kraj(czechy).
kraj(dania).
kraj(dominikana).
kraj(ekwador).
kraj(estonia).
kraj(eswatini).
kraj(finlandia).
kraj(francja).
kraj(niemcy).
kraj(ghana).
kraj(grecja).
kraj(grenlandia).
kraj(gwatemala).
kraj(wegry).
kraj(islandia).
kraj(indie).
kraj(indonezja).
kraj(irlandia).
kraj(izrael).
kraj(wlochy).
kraj(japonia).
kraj(jordania).
kraj(kenia).
kraj(kirgistan).
kraj(lotwa).
kraj(liban).
kraj(lesotho).
kraj(liechtenstein).
kraj(litwa).
kraj(luksemburg).
kraj(malezja).
kraj(meksyk).
kraj(mongolia).
kraj(czarnogora).
kraj(namibia).
kraj(niderlandy).
kraj(nowa_zelandia).
kraj(nigeria).
kraj(macedonia_polnocna).
kraj(norwegia).
kraj(oman).
kraj(palestyna).
kraj(panama).
kraj(peru).
kraj(filipiny).
kraj(polska).
kraj(portugalia).
kraj(katar).
kraj(rumunia).
kraj(rosja).
kraj(rwanda).
kraj(san_marino).
kraj(wyspy_swietego_tomasza_i_ksiazeca).
kraj(senegal).
kraj(serbia).
kraj(singapur).
kraj(slowacja).
kraj(slowenia).
kraj(poludniowa_afryka).
kraj(korea_poludniowa).
kraj(hiszpania).
kraj(sri_lanka).
kraj(szwecja).
kraj(szwajcaria).
kraj(tajwan).
kraj(tajlandia).
kraj(turcja).
kraj(tunezja).
kraj(ukraina).
kraj(uganda).
kraj(zjednoczone_emiraty_arabskie).
kraj(wielka_brytania).
kraj(usa).
kraj(urugwaj).
kraj(wietnam).
% kraj(...).

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
%
% --- Ruch i jezdnia ---
cecha_typ(ruch_lewostronny, bool).
cecha_typ(pasy_srodkowe_zolte, bool).
cecha_typ(linia_krawedziowa_biala, bool).
cecha_typ(droga_szeroka, fuzzy).
cecha_typ(jakosc_nawierzchni, fuzzy).
cecha_typ(typ_linii_jezdni, enum).
cecha_typ(typ_znaku_ograniczenia_predkosci, enum).
%
% --- Słupki, znaki i infrastruktura ---
cecha_typ(typ_slupka, enum).
cecha_typ(slupek_bialo_czerwony_aus, bool).
cecha_typ(znak_speed_limit_usa, bool).
cecha_typ(znak_ostrzegawczy_zolty_rombowy, bool).
cecha_typ(znak_nakazu_okragly, bool).
cecha_typ(typ_barierek_drogowych, enum).
cecha_typ(typ_latarni_ulicznych, enum).
%
% --- Tablice i pojazdy ---
cecha_typ(tablica_zolte_tyl, bool).
cecha_typ(tablica_dluga_eu, bool).
cecha_typ(tablica_krotka_przod, bool).
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
cecha_typ(dlugosc_napisow, fuzzy).
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
cecha_typ(obecnosc_iglastego_lasu, bool).
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
cecha_typ(poziom_bluru, fuzzy).
cecha_typ(polozenie_kamery_nad_ziemia, fuzzy).
cecha_typ(artefakty_laczenia_panorama, bool).

% =========================
% 3) Pytania dialogowe
% =========================
% pytanie(Id, Cecha, FormaOdpowiedzi, KontekstTag).
% FormaOdpowiedzi: radio | checkbox | slider | enum
% KontekstTag używaj do reguł kontekstowych wyboru pytania.
%
% --- Ruch i jezdnia ---
pytanie(q_ruch_lewostronny, ruch_lewostronny, radio, transport).
pytanie(q_pasy_srodkowe_zolte, pasy_srodkowe_zolte, radio, transport).
pytanie(q_linia_krawedziowa_biala, linia_krawedziowa_biala, radio, transport).
pytanie(q_droga_szeroka, droga_szeroka, slider, transport).
pytanie(q_jakosc_nawierzchni, jakosc_nawierzchni, slider, transport).
pytanie(q_typ_linii_jezdni, typ_linii_jezdni, enum, transport).
pytanie(q_typ_znaku_ograniczenia_predkosci, typ_znaku_ograniczenia_predkosci, enum, transport).
%
% --- Słupki, znaki i infrastruktura ---
pytanie(q_typ_slupka, typ_slupka, enum, infrastruktura).
pytanie(q_slupek_bialo_czerwony_aus, slupek_bialo_czerwony_aus, radio, infrastruktura).
pytanie(q_znak_speed_limit_usa, znak_speed_limit_usa, radio, infrastruktura).
pytanie(q_znak_ostrzegawczy_zolty_rombowy, znak_ostrzegawczy_zolty_rombowy, radio, infrastruktura).
pytanie(q_znak_nakazu_okragly, znak_nakazu_okragly, radio, infrastruktura).
pytanie(q_typ_barierek_drogowych, typ_barierek_drogowych, enum, infrastruktura).
pytanie(q_typ_latarni_ulicznych, typ_latarni_ulicznych, enum, infrastruktura).
%
% --- Tablice i pojazdy ---
pytanie(q_tablica_zolte_tyl, tablica_zolte_tyl, radio, tablice).
pytanie(q_tablica_dluga_eu, tablica_dluga_eu, radio, tablice).
pytanie(q_tablica_krotka_przod, tablica_krotka_przod, radio, tablice).
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
pytanie(q_dlugosc_napisow, dlugosc_napisow, slider, jezyk).
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
pytanie(q_obecnosc_iglastego_lasu, obecnosc_iglastego_lasu, radio, srodowisko).
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
pytanie(q_poziom_bluru, poziom_bluru, slider, meta).
pytanie(q_polozenie_kamery_nad_ziemia, polozenie_kamery_nad_ziemia, slider, meta).
pytanie(q_artefakty_laczenia_panorama, artefakty_laczenia_panorama, radio, meta).

% --- Wartości cech typu enum (szablon) ---
% enum_wartosci(Cecha, ListaWartosci).
enum_wartosci(typ_linii_jezdni, [ciagla, przerywana, podwojna_ciagla, mieszana]).
enum_wartosci(typ_znaku_ograniczenia_predkosci, [okragly_eu, prostokatny_usa, brak_rozpoznania]).
enum_wartosci(typ_slupka, [bialo_czerwony, betonowy, metalowy, drewniany, brak_charakterystycznego]).
enum_wartosci(typ_barierek_drogowych, [metalowe_faliste, betonowe, linowe, brak]).
enum_wartosci(typ_latarni_ulicznych, [wysokie_nowoczesne, niskie_klasyczne, brak]).
enum_wartosci(kolor_tylnej_tablicy, [bialy, zolty, czerwony, czarny, inny]).
enum_wartosci(format_tablicy_rejestracyjnej, [dluga_eu, krotka_usa, kwadratowa, niestandardowa]).
enum_wartosci(alfabet_dominujacy, [lacinski, cyrylica, arabski, han, hangul, mieszany]).
enum_wartosci(jezyk_na_znakach, [angielski, hiszpanski, francuski, niemiecki, arabski, rosyjski, japonski, koreanski, inny]).
enum_wartosci(typ_biomu, [umiarkowany, tropikalny, pustynny, borealny, wysokogorski, srodziemnomorski]).
enum_wartosci(styl_architektury, [skandynawski, kolonialny, modernistyczny, srodziemnomorski, postsowiecki, azjatycki, mieszany]).
enum_wartosci(typ_dachow, [dwuspadowy, plaski, blaszany, dachowka_ceramiczna, mieszany]).
enum_wartosci(kolorystyka_budynkow, [jasna, ceglana, pastelowa, szara, kontrastowa]).
enum_wartosci(generacja_kamery_google, [gen2, gen3, gen4, nieznana]).

% =========================
% 4) Reguły przybliżone (CF)
% =========================
% regula_cf(IdReguly, Kraj, Przeslanki, Waga, Priorytet).
% Przeslanki to lista literałów:
%   cecha(C, tak)
%   cecha(C, nie)
%   cecha_enum(C, Wartosc)
%   cecha_num(C, Min, Max)
%
% PAKIET STARTOWY (40 reguł)
% Uwaga: w prototypie inference_engine.pl odpowiedzi bool to yes/no.

% --- Australia (5) ---
regula_cf(r_cf_001, australia,
    [cecha(ruch_lewostronny, yes), cecha(slupek_bialo_czerwony_aus, yes)],
    0.90, 10).
regula_cf(r_cf_002, australia,
    [cecha_enum(typ_biomu, pustynny), cecha(obecnosc_palm, no)],
    0.65, 7).
regula_cf(r_cf_003, australia,
    [cecha_enum(typ_znaku_ograniczenia_predkosci, okragly_eu), cecha(ruch_lewostronny, yes)],
    0.55, 6).
regula_cf(r_cf_004, australia,
    [cecha_num(suchosc_klimatu, 65, 100), cecha_enum(jezyk_na_znakach, angielski)],
    0.70, 8).
regula_cf(r_cf_005, australia,
    [cecha_enum(kolor_tylnej_tablicy, bialy), cecha_enum(generacja_kamery_google, gen4)],
    0.45, 5).

% --- Stany Zjednoczone / usa (5) ---
regula_cf(r_cf_006, usa,
    [cecha(ruch_lewostronny, no), cecha(znak_speed_limit_usa, yes)],
    0.92, 10).
regula_cf(r_cf_007, usa,
    [cecha_enum(format_tablicy_rejestracyjnej, krotka_usa), cecha_enum(alfabet_dominujacy, lacinski)],
    0.78, 8).
regula_cf(r_cf_008, usa,
    [cecha(pasy_srodkowe_zolte, yes), cecha_enum(typ_znaku_ograniczenia_predkosci, prostokatny_usa)],
    0.83, 9).
regula_cf(r_cf_009, usa,
    [cecha_enum(jezyk_na_znakach, angielski), cecha(tablica_dluga_eu, no)],
    0.60, 7).
regula_cf(r_cf_010, usa,
    [cecha_enum(typ_barierek_drogowych, metalowe_faliste), cecha(obecnosc_domow_jednorodzinnych, yes)],
    0.50, 6).

% --- Wielka Brytania / uk (5) ---
regula_cf(r_cf_011, wielka_brytania,
    [cecha(ruch_lewostronny, yes), cecha(tablica_zolte_tyl, yes)],
    0.93, 10).
regula_cf(r_cf_012, wielka_brytania,
    [cecha(tablica_dluga_eu, yes), cecha_enum(jezyk_na_znakach, angielski)],
    0.75, 8).
regula_cf(r_cf_013, wielka_brytania,
    [cecha_enum(typ_biomu, umiarkowany), cecha_num(zachmurzenie, 50, 100)],
    0.52, 6).
regula_cf(r_cf_014, wielka_brytania,
    [cecha_enum(styl_architektury, kolonialny), cecha(obecnosc_blokow_mieszkalnych, no)],
    0.40, 4).
regula_cf(r_cf_015, wielka_brytania,
    [cecha_enum(kolor_tylnej_tablicy, zolty), cecha(ruch_lewostronny, yes)],
    0.86, 9).

% --- Japonia (5) ---
regula_cf(r_cf_016, japonia,
    [cecha(ruch_lewostronny, yes), cecha(kanji_obecne, yes)],
    0.95, 10).
regula_cf(r_cf_017, japonia,
    [cecha_enum(alfabet_dominujacy, han), cecha(tablica_krotka_przod, yes)],
    0.72, 8).
regula_cf(r_cf_018, japonia,
    [cecha_enum(styl_architektury, azjatycki), cecha_num(gestosc_zabudowy, 60, 100)],
    0.62, 7).
regula_cf(r_cf_019, japonia,
    [cecha_enum(typ_dachow, blaszany), cecha(obecnosc_gor_ostrych, yes)],
    0.48, 5).
regula_cf(r_cf_020, japonia,
    [cecha_enum(generacja_kamery_google, gen4), cecha_num(poziom_bluru, 0, 40)],
    0.35, 4).

% --- Korea Południowa (5) ---
regula_cf(r_cf_021, korea_poludniowa,
    [cecha(hangul_obecny, yes), cecha(ruch_lewostronny, no)],
    0.94, 10).
regula_cf(r_cf_022, korea_poludniowa,
    [cecha_enum(alfabet_dominujacy, hangul), cecha_num(gestosc_zabudowy, 60, 100)],
    0.80, 8).
regula_cf(r_cf_023, korea_poludniowa,
    [cecha_enum(styl_architektury, azjatycki), cecha(obecnosc_blokow_mieszkalnych, yes)],
    0.68, 7).
regula_cf(r_cf_024, korea_poludniowa,
    [cecha_enum(jezyk_na_znakach, koreanski), cecha_enum(typ_dachow, plaski)],
    0.74, 8).
regula_cf(r_cf_025, korea_poludniowa,
    [cecha_enum(generacja_kamery_google, gen4), cecha_num(polozenie_kamery_nad_ziemia, 40, 70)],
    0.40, 5).

% --- Brazylia (5) ---
regula_cf(r_cf_026, brazylia,
    [cecha_enum(jezyk_na_znakach, inny), cecha(obecnosc_palm, yes)],
    0.65, 7).
regula_cf(r_cf_027, brazylia,
    [cecha_enum(typ_biomu, tropikalny), cecha_num(wilgotnosc_klimatu, 60, 100)],
    0.79, 8).
regula_cf(r_cf_028, brazylia,
    [cecha(ruch_lewostronny, no), cecha_enum(kolorystyka_budynkow, pastelowa)],
    0.52, 6).
regula_cf(r_cf_029, brazylia,
    [cecha_num(obecnosc_motocykli, 50, 100), cecha(obecnosc_domow_jednorodzinnych, yes)],
    0.47, 5).
regula_cf(r_cf_030, brazylia,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(alfabet_dominujacy, lacinski)],
    0.38, 4).

% --- Szwecja (5) ---
regula_cf(r_cf_031, szwecja,
    [cecha(ruch_lewostronny, no), cecha(obecnosc_iglastego_lasu, yes)],
    0.72, 8).
regula_cf(r_cf_032, szwecja,
    [cecha_enum(styl_architektury, skandynawski), cecha_num(zachmurzenie, 40, 100)],
    0.76, 8).
regula_cf(r_cf_033, szwecja,
    [cecha_enum(typ_biomu, borealny), cecha(obecnosc_sniegu, yes)],
    0.70, 7).
regula_cf(r_cf_034, szwecja,
    [cecha_enum(kolorystyka_budynkow, jasna), cecha_enum(typ_dachow, dwuspadowy)],
    0.45, 5).
regula_cf(r_cf_035, szwecja,
    [cecha_num(wysokosc_roslinnosci, 40, 80), cecha_num(zageszczenie_lasu, 50, 100)],
    0.58, 6).

% --- Zjednoczone Emiraty Arabskie (5) ---
regula_cf(r_cf_036, zjednoczone_emiraty_arabskie,
    [cecha(arabski_obecny, yes), cecha_enum(typ_biomu, pustynny)],
    0.91, 10).
regula_cf(r_cf_037, zjednoczone_emiraty_arabskie,
    [cecha_num(suchosc_klimatu, 75, 100), cecha(obecnosc_pustyni, yes)],
    0.88, 9).
regula_cf(r_cf_038, zjednoczone_emiraty_arabskie,
    [cecha_enum(styl_architektury, modernistyczny), cecha_num(wysokosc_budynkow, 70, 100)],
    0.66, 7).
regula_cf(r_cf_039, zjednoczone_emiraty_arabskie,
    [cecha_enum(jezyk_na_znakach, arabski), cecha(dostep_do_morza_widoczny, yes)],
    0.60, 7).
regula_cf(r_cf_040, zjednoczone_emiraty_arabskie,
    [cecha_enum(generacja_kamery_google, gen4), cecha_enum(kolorystyka_budynkow, jasna)],
    0.42, 5).

% =========================
% 5) Reguły rozmyte
% =========================
% regula_fuzzy(IdReguly, Kraj, Zmienna, EtykietaLingwistyczna, Waga).
% Etykiety przykładowe:
%   plaski / pagorkowaty / gorzysty
regula_fuzzy(r_fz_001, szwajcaria, gorzystosc_terenu, gorzysty, 0.85).
regula_fuzzy(r_fz_002, australia, gorzystosc_terenu, plaski, 0.55).

% =========================
% 6) Weta (warunki wykluczające)
% =========================
% weto(Kraj, Warunek, Prog).
% Warunek opisuje przesłankę, a Prog - próg aktywacji.
weto(usa, cecha(ruch_lewostronny, tak), 0.70).
weto(australia, cecha(tablica_zolte_tyl, nie), 0.80).

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

