% ProGeoLog - szablon bazy wiedzy
% Uzupełniaj symbole konsekwentnie i nie zmieniaj typów danych.

:- module(knowledge_base, [
    kraj/1,
    kraj_ui_label/2,
    jezyk_urzedowy_kraju/2,
    pytanie/4,
    cecha_typ/2,
    enum_wartosci/2,
    enum_wartosc/2,
    regula_cf/5,
    regula_fuzzy/5,
    weto/3,
    weto_zakaz/4
]).

% =========================
% 1) Kraje (decyzje)
% =========================
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

% Języki urzędowe / typowe na znakach drogowych (wiele faktów na kraj).
% Weto językowe w inference_engine: obserwacja L wyklucza kraj bez jezyk_urzedowy_kraju(K, L).
% Przy dodawaniu kraju: dopisz kraj/1 oraz jeden lub więcej jezyk_urzedowy_kraju/2.
jezyk_urzedowy_kraju(argentyna, hiszpanski).
jezyk_urzedowy_kraju(australia, angielski).
jezyk_urzedowy_kraju(brazylia, portugalski).
jezyk_urzedowy_kraju(rosja, rosyjski).
jezyk_urzedowy_kraju(senegal, francuski).
jezyk_urzedowy_kraju(singapur, angielski).
jezyk_urzedowy_kraju(poludniowa_afryka, angielski).
jezyk_urzedowy_kraju(korea_poludniowa, koreanski).
jezyk_urzedowy_kraju(sri_lanka, syngaleski).
jezyk_urzedowy_kraju(sri_lanka, angielski).
jezyk_urzedowy_kraju(zjednoczone_emiraty_arabskie, arabski).
jezyk_urzedowy_kraju(wielka_brytania, angielski).
jezyk_urzedowy_kraju(usa, angielski).
% kraj(kanada). jezyk_urzedowy_kraju(kanada, angielski). jezyk_urzedowy_kraju(kanada, francuski).

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
% enum — dyskretne; fuzzy — skala 0..100 (bez duplikatów wilgotność/suchość)

cecha_typ(dostep_do_morza, enum).
cecha_typ(format_tablicy_rejestracyjnej, enum).
cecha_typ(generacja_kamery_google, enum).
cecha_typ(jezyk_na_znakach, enum).
cecha_typ(kolor_tylnej_tablicy, enum).
cecha_typ(kolor_znaku_ograniczenia_predkosci, enum).
cecha_typ(kolor_znaku_ostrzegawczego, enum).
cecha_typ(kolorystyka_budynkow, enum).
cecha_typ(ksztalt_znaku_ograniczenia_predkosci, enum).
cecha_typ(ksztalt_znaku_ostrzegawczego, enum).
cecha_typ(obecnosc_blokow_mieszkalnych, enum).
cecha_typ(obecnosc_domow_jednorodzinnych, enum).
cecha_typ(obecnosc_gor_ostrych, enum).
cecha_typ(obecnosc_palm, enum).
cecha_typ(obecnosc_pustyni, enum).
cecha_typ(obecnosc_rownin, enum).
cecha_typ(obecnosc_sniegu, enum).
cecha_typ(pasy_srodkowe_zolte, enum).
cecha_typ(polkula, enum).
cecha_typ(strona_ruchu, enum).
cecha_typ(styl_architektury, enum).
cecha_typ(typ_barierek_drogowych, enum).
cecha_typ(typ_biomu, enum).
cecha_typ(typ_dachow, enum).
cecha_typ(wzor_slupka_drogowego, enum).

cecha_typ(droga_szeroka, fuzzy).
cecha_typ(gestosc_zabudowy, fuzzy).
cecha_typ(gorzystosc_terenu, fuzzy).
cecha_typ(jakosc_nawierzchni, fuzzy).
cecha_typ(obecnosc_motocykli, fuzzy).
cecha_typ(polozenie_kamery_nad_ziemia, fuzzy).
cecha_typ(suchosc_klimatu, fuzzy).
cecha_typ(wysokosc_budynkow, fuzzy).
cecha_typ(wysokosc_roslinnosci, fuzzy).
cecha_typ(zachmurzenie, fuzzy).
cecha_typ(zageszczenie_lasu, fuzzy).
% =========================
% 3) Pytania dialogowe
% =========================

pytanie(q_dostep_do_morza, dostep_do_morza, enum, geografia).
pytanie(q_format_tablicy_rejestracyjnej, format_tablicy_rejestracyjnej, enum, tablice).
pytanie(q_generacja_kamery_google, generacja_kamery_google, enum, meta).
pytanie(q_jezyk_na_znakach, jezyk_na_znakach, enum, jezyk).
pytanie(q_kolor_tylnej_tablicy, kolor_tylnej_tablicy, enum, tablice).
pytanie(q_kolor_znaku_ograniczenia, kolor_znaku_ograniczenia_predkosci, enum, infrastruktura).
pytanie(q_kolor_znaku_ostrzegawczego, kolor_znaku_ostrzegawczego, enum, infrastruktura).
pytanie(q_kolorystyka_budynkow, kolorystyka_budynkow, enum, zabudowa).
pytanie(q_ksztalt_znaku_ograniczenia, ksztalt_znaku_ograniczenia_predkosci, enum, infrastruktura).
pytanie(q_ksztalt_znaku_ostrzegawczego, ksztalt_znaku_ostrzegawczego, enum, infrastruktura).
pytanie(q_obecnosc_blokow_mieszkalnych, obecnosc_blokow_mieszkalnych, enum, zabudowa).
pytanie(q_obecnosc_domow_jednorodzinnych, obecnosc_domow_jednorodzinnych, enum, zabudowa).
pytanie(q_obecnosc_gor_ostrych, obecnosc_gor_ostrych, enum, geografia).
pytanie(q_obecnosc_palm, obecnosc_palm, enum, srodowisko).
pytanie(q_obecnosc_pustyni, obecnosc_pustyni, enum, geografia).
pytanie(q_obecnosc_rownin, obecnosc_rownin, enum, geografia).
pytanie(q_obecnosc_sniegu, obecnosc_sniegu, enum, geografia).
pytanie(q_polkula, polkula, enum, geografia).
pytanie(q_pasy_srodkowe_zolte, pasy_srodkowe_zolte, enum, transport).
pytanie(q_strona_ruchu, strona_ruchu, enum, transport).
pytanie(q_styl_architektury, styl_architektury, enum, zabudowa).
pytanie(q_typ_barierek_drogowych, typ_barierek_drogowych, enum, infrastruktura).
pytanie(q_typ_biomu, typ_biomu, enum, srodowisko).
pytanie(q_typ_dachow, typ_dachow, enum, zabudowa).
pytanie(q_wzor_slupka_drogowego, wzor_slupka_drogowego, enum, infrastruktura).

pytanie(q_droga_szeroka, droga_szeroka, slider, transport).
pytanie(q_gestosc_zabudowy, gestosc_zabudowy, slider, zabudowa).
pytanie(q_gorzystosc_terenu, gorzystosc_terenu, slider, srodowisko).
pytanie(q_jakosc_nawierzchni, jakosc_nawierzchni, slider, transport).
pytanie(q_obecnosc_motocykli, obecnosc_motocykli, slider, tablice).
pytanie(q_polozenie_kamery_nad_ziemia, polozenie_kamery_nad_ziemia, slider, meta).
pytanie(q_suchosc_klimatu, suchosc_klimatu, slider, srodowisko).
pytanie(q_wysokosc_budynkow, wysokosc_budynkow, slider, zabudowa).
pytanie(q_wysokosc_roslinnosci, wysokosc_roslinnosci, slider, srodowisko).
pytanie(q_zachmurzenie, zachmurzenie, slider, srodowisko).
pytanie(q_zageszczenie_lasu, zageszczenie_lasu, slider, srodowisko).

% --- Wartości enum ---
enum_wartosci(dostep_do_morza, [widoczny, brak, nie_wiem]).
enum_wartosci(format_tablicy_rejestracyjnej, [dluga_eu, krotka_usa, kwadratowa, niestandardowa, nie_wiem]).
enum_wartosci(generacja_kamery_google, [gen2, gen3, gen4, nieznana, nie_wiem]).
enum_wartosci(jezyk_na_znakach, [angielski, hiszpanski, portugalski, francuski, niemiecki, arabski, rosyjski, japonski, koreanski, syngaleski, inny, nie_wiem]).
enum_wartosci(kolor_tylnej_tablicy, [bialy, zolty, czerwony, czarny, inny, nie_wiem]).
enum_wartosci(kolor_znaku_ograniczenia_predkosci, [bialy_czarny_napis, z_czerwona_obwodka, inny, nie_wiem]).
enum_wartosci(kolor_znaku_ostrzegawczego, [zolty_czarny, czerwony_bialy, inny, nie_wiem]).
enum_wartosci(kolorystyka_budynkow, [jasna, ceglana, pastelowa, szara, kontrastowa, nie_wiem]).
enum_wartosci(ksztalt_znaku_ograniczenia_predkosci, [okragly, prostokatny, trojkatny, inny, nie_wiem]).
enum_wartosci(ksztalt_znaku_ostrzegawczego, [romb, trojkat, okrag, inny, nie_wiem]).
enum_wartosci(obecnosc_blokow_mieszkalnych, [obecna, brak, nie_wiem]).
enum_wartosci(obecnosc_domow_jednorodzinnych, [obecna, brak, nie_wiem]).
enum_wartosci(obecnosc_gor_ostrych, [obecna, brak, nie_wiem]).
enum_wartosci(obecnosc_palm, [obecna, brak, nie_wiem]).
enum_wartosci(obecnosc_pustyni, [obecna, brak, nie_wiem]).
enum_wartosci(obecnosc_rownin, [obecna, brak, nie_wiem]).
enum_wartosci(obecnosc_sniegu, [obecna, brak, nie_wiem]).
enum_wartosci(pasy_srodkowe_zolte, [widoczne, brak, nie_wiem]).
enum_wartosci(polkula, [pln, pld, nie_wiem]).
enum_wartosci(strona_ruchu, [lewostronny, prawostronny, nie_wiem]).
enum_wartosci(styl_architektury, [skandynawski, kolonialny, modernistyczny, srodziemnomorski, postsowiecki, azjatycki, mieszany, nie_wiem]).
enum_wartosci(typ_barierek_drogowych, [metalowe_faliste, betonowe, linowe, brak, nie_wiem]).
enum_wartosci(typ_biomu, [umiarkowany, tropikalny, pustynny, borealny, wysokogorski, srodziemnomorski, nie_wiem]).
enum_wartosci(typ_dachow, [dwuspadowy, plaski, blaszany, dachowka_ceramiczna, mieszany, nie_wiem]).
enum_wartosci(wzor_slupka_drogowego, [pasy_bialo_czerwone, jednokolorowy, betonowy, inny, nie_wiem]).

enum_wartosc(Cecha, W) :-
    enum_wartosci(Cecha, Lista),
    member(W, Lista).

% Konkluzje (hipoteza/2, wynik_koncowy/2) nie są tu zapisane — powstają dynamicznie
% w inference_engine.pl na podstawie reguł produkcji i odpowiedzi użytkownika (konspekt §4.2).

% =========================
% 4) Reguły przybliżone (CF)
% =========================
% regula_cf(IdReguly, Kraj, Przeslanki, Waga, Priorytet).
% Pakiet 100 reguł CF — bool/enum; fuzzy w sekcji 5.

regula_cf(r_cf_001, argentyna,
    [cecha_enum(jezyk_na_znakach, hiszpanski), cecha_enum(strona_ruchu, prawostronny)],
    0.88, 10).
regula_cf(r_cf_002, argentyna,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(jezyk_na_znakach, hiszpanski)],
    0.72, 8).
regula_cf(r_cf_003, argentyna,
    [cecha_enum(obecnosc_rownin, obecna), cecha_enum(typ_biomu, umiarkowany)],
    0.65, 7).
regula_cf(r_cf_004, argentyna,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(strona_ruchu, prawostronny)],
    0.58, 7).
regula_cf(r_cf_005, argentyna,
    [cecha_enum(kolorystyka_budynkow, pastelowa), cecha_enum(typ_biomu, tropikalny)],
    0.52, 6).
regula_cf(r_cf_006, argentyna,
    [cecha_enum(typ_biomu, pustynny), cecha_enum(obecnosc_palm, brak)],
    0.62, 6).
regula_cf(r_cf_007, argentyna,
    [cecha_num(suchosc_klimatu, 40, 75), cecha_enum(styl_architektury, mieszany)],
    0.45, 5).
regula_cf(r_cf_008, argentyna,
    [cecha_enum(ksztalt_znaku_ograniczenia_predkosci, okragly), cecha_enum(kolor_znaku_ograniczenia_predkosci, bialy_czarny_napis)],
    0.42, 5).
regula_cf(r_cf_009, australia,
    [cecha_enum(strona_ruchu, lewostronny), cecha_enum(wzor_slupka_drogowego, pasy_bialo_czerwone)],
    0.92, 10).
regula_cf(r_cf_010, australia,
    [cecha_enum(typ_biomu, pustynny), cecha_enum(obecnosc_palm, brak)],
    0.62, 6).
regula_cf(r_cf_011, australia,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(strona_ruchu, lewostronny)],
    0.75, 8).
regula_cf(r_cf_012, australia,
    [cecha_num(suchosc_klimatu, 65, 100), cecha_enum(typ_biomu, pustynny)],
    0.72, 8).
regula_cf(r_cf_013, australia,
    [cecha_enum(kolor_tylnej_tablicy, bialy), cecha_enum(generacja_kamery_google, gen4)],
    0.55, 7).
regula_cf(r_cf_014, australia,
    [cecha_enum(ksztalt_znaku_ograniczenia_predkosci, okragly), cecha_enum(kolor_znaku_ograniczenia_predkosci, bialy_czarny_napis)],
    0.50, 6).
regula_cf(r_cf_015, australia,
    [cecha_enum(obecnosc_pustyni, obecna), cecha_num(zachmurzenie, 20, 60)],
    0.62, 7).
regula_cf(r_cf_016, australia,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(obecnosc_sniegu, brak)],
    0.48, 5).
regula_cf(r_cf_017, australia,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(dostep_do_morza, widoczny)],
    0.44, 5).
regula_cf(r_cf_018, brazylia,
    [cecha_enum(typ_biomu, tropikalny), cecha_num(suchosc_klimatu, 0, 40)],
    0.85, 10).
regula_cf(r_cf_019, brazylia,
    [cecha_enum(jezyk_na_znakach, portugalski), cecha_enum(obecnosc_palm, obecna)],
    0.78, 9).
regula_cf(r_cf_020, brazylia,
    [cecha_enum(strona_ruchu, prawostronny), cecha_enum(kolorystyka_budynkow, pastelowa)],
    0.70, 8).
regula_cf(r_cf_021, brazylia,
    [cecha_num(obecnosc_motocykli, 50, 100), cecha_enum(obecnosc_domow_jednorodzinnych, obecna)],
    0.58, 7).
regula_cf(r_cf_022, brazylia,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(jezyk_na_znakach, portugalski)],
    0.52, 6).
regula_cf(r_cf_023, brazylia,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(typ_biomu, tropikalny)],
    0.55, 7).
regula_cf(r_cf_024, brazylia,
    [cecha_enum(jezyk_na_znakach, portugalski), cecha_enum(strona_ruchu, prawostronny)],
    0.48, 5).
regula_cf(r_cf_025, brazylia,
    [cecha_enum(obecnosc_gor_ostrych, brak), cecha_num(gestosc_zabudowy, 40, 80)],
    0.42, 5).
regula_cf(r_cf_026, rosja,
    [cecha_enum(jezyk_na_znakach, rosyjski), cecha_enum(styl_architektury, postsowiecki)],
    0.92, 10).
regula_cf(r_cf_027, rosja,
    [cecha_enum(jezyk_na_znakach, rosyjski), cecha_enum(styl_architektury, postsowiecki)],
    0.88, 10).
regula_cf(r_cf_028, rosja,
    [cecha_enum(jezyk_na_znakach, rosyjski), cecha_enum(strona_ruchu, prawostronny)],
    0.72, 8).
regula_cf(r_cf_029, rosja,
    [cecha_enum(typ_biomu, borealny), cecha_enum(obecnosc_sniegu, obecna)],
    0.68, 8).
regula_cf(r_cf_030, rosja,
    [cecha_enum(typ_biomu, srodziemnomorski), cecha_enum(jezyk_na_znakach, rosyjski)],
    0.62, 7).
regula_cf(r_cf_031, rosja,
    [cecha_enum(generacja_kamery_google, gen3), cecha_enum(styl_architektury, postsowiecki)],
    0.55, 7).
regula_cf(r_cf_032, rosja,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(jezyk_na_znakach, rosyjski)],
    0.50, 6).
regula_cf(r_cf_033, rosja,
    [cecha_num(zachmurzenie, 50, 100), cecha_enum(kolorystyka_budynkow, szara)],
    0.45, 5).
regula_cf(r_cf_034, senegal,
    [cecha_enum(jezyk_na_znakach, francuski), cecha_enum(typ_biomu, tropikalny)],
    0.86, 10).
regula_cf(r_cf_035, senegal,
    [cecha_num(suchosc_klimatu, 55, 90), cecha_enum(obecnosc_pustyni, brak)],
    0.75, 8).
regula_cf(r_cf_036, senegal,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(strona_ruchu, prawostronny)],
    0.70, 8).
regula_cf(r_cf_037, senegal,
    [cecha_enum(obecnosc_palm, obecna), cecha_enum(typ_biomu, tropikalny)],
    0.68, 7).
regula_cf(r_cf_038, senegal,
    [cecha_enum(jezyk_na_znakach, francuski), cecha_enum(styl_architektury, kolonialny)],
    0.62, 7).
regula_cf(r_cf_039, senegal,
    [cecha_enum(kolorystyka_budynkow, pastelowa), cecha_enum(dostep_do_morza, widoczny)],
    0.58, 6).
regula_cf(r_cf_040, senegal,
    [cecha_enum(jezyk_na_znakach, francuski), cecha_enum(kolorystyka_budynkow, pastelowa)],
    0.48, 5).
regula_cf(r_cf_041, senegal,
    [cecha_enum(typ_biomu, pustynny), cecha_enum(obecnosc_palm, brak)],
    0.58, 6).
regula_cf(r_cf_042, singapur,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(styl_architektury, modernistyczny)],
    0.90, 10).
regula_cf(r_cf_043, singapur,
    [cecha_enum(strona_ruchu, prawostronny), cecha_num(gestosc_zabudowy, 75, 100)],
    0.85, 9).
regula_cf(r_cf_044, singapur,
    [cecha_enum(typ_biomu, tropikalny), cecha_num(suchosc_klimatu, 0, 30)],
    0.78, 8).
regula_cf(r_cf_045, singapur,
    [cecha_enum(styl_architektury, azjatycki), cecha_enum(obecnosc_blokow_mieszkalnych, obecna)],
    0.72, 8).
regula_cf(r_cf_046, singapur,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(styl_architektury, azjatycki)],
    0.65, 7).
regula_cf(r_cf_047, singapur,
    [cecha_enum(generacja_kamery_google, gen4), cecha_num(wysokosc_budynkow, 60, 100)],
    0.60, 7).
regula_cf(r_cf_048, singapur,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(strona_ruchu, prawostronny)],
    0.52, 6).
regula_cf(r_cf_049, singapur,
    [cecha_enum(kolorystyka_budynkow, jasna), cecha_enum(dostep_do_morza, widoczny)],
    0.50, 6).
regula_cf(r_cf_050, poludniowa_afryka,
    [cecha_enum(strona_ruchu, lewostronny), cecha_enum(jezyk_na_znakach, angielski)],
    0.90, 10).
regula_cf(r_cf_051, poludniowa_afryka,
    [cecha_enum(kolor_tylnej_tablicy, zolty), cecha_enum(strona_ruchu, lewostronny)],
    0.82, 9).
regula_cf(r_cf_052, poludniowa_afryka,
    [cecha_enum(typ_biomu, umiarkowany), cecha_enum(styl_architektury, kolonialny)],
    0.70, 8).
regula_cf(r_cf_053, poludniowa_afryka,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(styl_architektury, kolonialny)],
    0.65, 7).
regula_cf(r_cf_054, poludniowa_afryka,
    [cecha_enum(obecnosc_gor_ostrych, obecna), cecha_enum(dostep_do_morza, widoczny)],
    0.62, 7).
regula_cf(r_cf_055, poludniowa_afryka,
    [cecha_enum(kolor_tylnej_tablicy, zolty), cecha_enum(format_tablicy_rejestracyjnej, dluga_eu)],
    0.58, 6).
regula_cf(r_cf_056, poludniowa_afryka,
    [cecha_enum(typ_biomu, pustynny), cecha_enum(obecnosc_palm, brak)],
    0.62, 6).
regula_cf(r_cf_057, poludniowa_afryka,
    [cecha_enum(typ_biomu, srodziemnomorski), cecha_num(zachmurzenie, 30, 70)],
    0.48, 5).
regula_cf(r_cf_058, korea_poludniowa,
    [cecha_enum(jezyk_na_znakach, koreanski), cecha_enum(strona_ruchu, prawostronny)],
    0.94, 10).
regula_cf(r_cf_059, korea_poludniowa,
    [cecha_enum(jezyk_na_znakach, koreanski), cecha_enum(styl_architektury, azjatycki)],
    0.90, 10).
regula_cf(r_cf_060, korea_poludniowa,
    [cecha_enum(styl_architektury, azjatycki), cecha_num(gestosc_zabudowy, 60, 100)],
    0.78, 8).
regula_cf(r_cf_061, korea_poludniowa,
    [cecha_enum(jezyk_na_znakach, koreanski), cecha_enum(typ_dachow, plaski)],
    0.74, 8).
regula_cf(r_cf_062, korea_poludniowa,
    [cecha_enum(obecnosc_blokow_mieszkalnych, obecna), cecha_enum(styl_architektury, azjatycki)],
    0.68, 7).
regula_cf(r_cf_063, korea_poludniowa,
    [cecha_enum(generacja_kamery_google, gen4), cecha_num(polozenie_kamery_nad_ziemia, 40, 70)],
    0.55, 7).
regula_cf(r_cf_064, korea_poludniowa,
    [cecha_enum(jezyk_na_znakach, koreanski), cecha_enum(typ_dachow, plaski)],
    0.60, 6).
regula_cf(r_cf_065, korea_poludniowa,
    [cecha_enum(typ_biomu, umiarkowany), cecha_enum(obecnosc_sniegu, obecna)],
    0.52, 6).
regula_cf(r_cf_066, korea_poludniowa,
    [cecha_enum(kolorystyka_budynkow, szara), cecha_enum(strona_ruchu, prawostronny)],
    0.45, 5).
regula_cf(r_cf_067, sri_lanka,
    [cecha_enum(strona_ruchu, lewostronny), cecha_enum(jezyk_na_znakach, angielski)],
    0.88, 10).
regula_cf(r_cf_068, sri_lanka,
    [cecha_enum(typ_biomu, tropikalny), cecha_enum(obecnosc_palm, obecna)],
    0.82, 9).
regula_cf(r_cf_069, sri_lanka,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(strona_ruchu, lewostronny)],
    0.75, 8).
regula_cf(r_cf_070, sri_lanka,
    [cecha_num(suchosc_klimatu, 0, 35), cecha_enum(typ_biomu, tropikalny)],
    0.72, 8).
regula_cf(r_cf_071, sri_lanka,
    [cecha_enum(styl_architektury, azjatycki), cecha_enum(obecnosc_gor_ostrych, obecna)],
    0.58, 6).
regula_cf(r_cf_072, sri_lanka,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(kolor_tylnej_tablicy, zolty)],
    0.55, 7).
regula_cf(r_cf_073, sri_lanka,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(styl_architektury, kolonialny)],
    0.50, 6).
regula_cf(r_cf_074, sri_lanka,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(dostep_do_morza, widoczny)],
    0.48, 5).
regula_cf(r_cf_075, zjednoczone_emiraty_arabskie,
    [cecha_enum(jezyk_na_znakach, arabski), cecha_enum(typ_biomu, pustynny)],
    0.93, 10).
regula_cf(r_cf_076, zjednoczone_emiraty_arabskie,
    [cecha_num(suchosc_klimatu, 75, 100), cecha_enum(obecnosc_pustyni, obecna)],
    0.90, 10).
regula_cf(r_cf_077, zjednoczone_emiraty_arabskie,
    [cecha_enum(jezyk_na_znakach, arabski), cecha_enum(typ_biomu, pustynny)],
    0.85, 9).
regula_cf(r_cf_078, zjednoczone_emiraty_arabskie,
    [cecha_enum(styl_architektury, modernistyczny), cecha_num(wysokosc_budynkow, 70, 100)],
    0.78, 8).
regula_cf(r_cf_079, zjednoczone_emiraty_arabskie,
    [cecha_enum(jezyk_na_znakach, arabski), cecha_enum(dostep_do_morza, widoczny)],
    0.72, 8).
regula_cf(r_cf_080, zjednoczone_emiraty_arabskie,
    [cecha_enum(generacja_kamery_google, gen4), cecha_enum(kolorystyka_budynkow, jasna)],
    0.55, 7).
regula_cf(r_cf_081, zjednoczone_emiraty_arabskie,
    [cecha_enum(strona_ruchu, prawostronny), cecha_enum(obecnosc_sniegu, brak)],
    0.62, 7).
regula_cf(r_cf_082, zjednoczone_emiraty_arabskie,
    [cecha_enum(typ_biomu, pustynny), cecha_enum(obecnosc_palm, brak)],
    0.62, 6).
regula_cf(r_cf_083, zjednoczone_emiraty_arabskie,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(jezyk_na_znakach, arabski)],
    0.48, 5).
regula_cf(r_cf_084, wielka_brytania,
    [cecha_enum(strona_ruchu, lewostronny), cecha_enum(kolor_tylnej_tablicy, zolty)],
    0.94, 10).
regula_cf(r_cf_085, wielka_brytania,
    [cecha_enum(format_tablicy_rejestracyjnej, dluga_eu), cecha_enum(jezyk_na_znakach, angielski)],
    0.82, 9).
regula_cf(r_cf_086, wielka_brytania,
    [cecha_enum(kolor_tylnej_tablicy, zolty), cecha_enum(strona_ruchu, lewostronny)],
    0.88, 9).
regula_cf(r_cf_087, wielka_brytania,
    [cecha_enum(typ_biomu, umiarkowany), cecha_num(zachmurzenie, 50, 100)],
    0.65, 7).
regula_cf(r_cf_088, wielka_brytania,
    [cecha_enum(styl_architektury, kolonialny), cecha_enum(obecnosc_blokow_mieszkalnych, brak)],
    0.55, 6).
regula_cf(r_cf_089, wielka_brytania,
    [cecha_enum(ksztalt_znaku_ograniczenia_predkosci, okragly), cecha_enum(kolor_znaku_ograniczenia_predkosci, bialy_czarny_napis)],
    0.60, 7).
regula_cf(r_cf_090, wielka_brytania,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(styl_architektury, kolonialny)],
    0.52, 6).
regula_cf(r_cf_091, wielka_brytania,
    [cecha_enum(obecnosc_sniegu, brak), cecha_num(suchosc_klimatu, 20, 55)],
    0.48, 5).
regula_cf(r_cf_092, wielka_brytania,
    [cecha_enum(styl_architektury, skandynawski), cecha_enum(typ_dachow, dwuspadowy)],
    0.40, 4).
regula_cf(r_cf_093, usa,
    [cecha_enum(ksztalt_znaku_ograniczenia_predkosci, prostokatny), cecha_enum(kolor_znaku_ograniczenia_predkosci, z_czerwona_obwodka)],
    0.94, 10).
regula_cf(r_cf_094, usa,
    [cecha_enum(format_tablicy_rejestracyjnej, krotka_usa), cecha_enum(jezyk_na_znakach, angielski)],
    0.85, 9).
regula_cf(r_cf_095, usa,
    [cecha_enum(pasy_srodkowe_zolte, widoczne), cecha_enum(kolor_znaku_ograniczenia_predkosci, z_czerwona_obwodka)],
    0.88, 9).
regula_cf(r_cf_096, usa,
    [cecha_enum(jezyk_na_znakach, angielski), cecha_enum(format_tablicy_rejestracyjnej, krotka_usa)],
    0.72, 8).
regula_cf(r_cf_097, usa,
    [cecha_enum(typ_barierek_drogowych, metalowe_faliste), cecha_enum(obecnosc_domow_jednorodzinnych, obecna)],
    0.65, 7).
regula_cf(r_cf_098, usa,
    [cecha_enum(typ_biomu, umiarkowany), cecha_enum(strona_ruchu, prawostronny)],
    0.58, 6).
regula_cf(r_cf_099, usa,
    [cecha_enum(ksztalt_znaku_ostrzegawczego, romb), cecha_enum(kolor_znaku_ostrzegawczego, zolty_czarny)],
    0.62, 7).
regula_cf(r_cf_100, usa,
    [cecha_enum(typ_biomu, pustynny), cecha_enum(obecnosc_palm, brak)],
    0.58, 6).

% Język na znakach — jedna przesłanka (waga bazowa 1.0; skalowanie 1/N w inference_engine).
% N = liczba aktywnych krajów z tą wartością języka w regułach CF; nowy kraj → niższy wynik.
regula_cf(r_cf_101, senegal,
    [cecha_enum(jezyk_na_znakach, francuski)], 1.0, 10).
regula_cf(r_cf_102, rosja,
    [cecha_enum(jezyk_na_znakach, rosyjski)], 1.0, 10).
regula_cf(r_cf_103, korea_poludniowa,
    [cecha_enum(jezyk_na_znakach, koreanski)], 1.0, 10).
regula_cf(r_cf_104, brazylia,
    [cecha_enum(jezyk_na_znakach, portugalski)], 1.0, 10).
regula_cf(r_cf_105, sri_lanka,
    [cecha_enum(jezyk_na_znakach, syngaleski)], 1.0, 10).
regula_cf(r_cf_106, argentyna,
    [cecha_enum(jezyk_na_znakach, hiszpanski)], 1.0, 10).
regula_cf(r_cf_107, zjednoczone_emiraty_arabskie,
    [cecha_enum(jezyk_na_znakach, arabski)], 1.0, 10).

% =========================
% 5) Reguły rozmyte (30 — 2–3 na kraj aktywny)
% =========================
% regula_fuzzy(IdReguly, Kraj, Zmienna, EtykietaLingwistyczna, Waga).

regula_fuzzy(r_fz_001, argentyna, suchosc_klimatu, pagorkowaty, 0.50).
regula_fuzzy(r_fz_002, argentyna, gestosc_zabudowy, pagorkowaty, 0.45).
regula_fuzzy(r_fz_003, australia, gorzystosc_terenu, plaski, 0.65).
regula_fuzzy(r_fz_004, australia, suchosc_klimatu, gorzysty, 0.70).
regula_fuzzy(r_fz_005, australia, wysokosc_roslinnosci, plaski, 0.55).
regula_fuzzy(r_fz_006, brazylia, suchosc_klimatu, plaski, 0.72).
regula_fuzzy(r_fz_007, brazylia, obecnosc_motocykli, gorzysty, 0.58).
regula_fuzzy(r_fz_008, brazylia, gorzystosc_terenu, plaski, 0.48).
regula_fuzzy(r_fz_009, rosja, zachmurzenie, gorzysty, 0.55).
regula_fuzzy(r_fz_010, rosja, wysokosc_roslinnosci, pagorkowaty, 0.50).
regula_fuzzy(r_fz_011, rosja, gorzystosc_terenu, pagorkowaty, 0.48).
regula_fuzzy(r_fz_012, senegal, suchosc_klimatu, gorzysty, 0.62).
regula_fuzzy(r_fz_013, senegal, suchosc_klimatu, pagorkowaty, 0.52).
regula_fuzzy(r_fz_014, singapur, gestosc_zabudowy, gorzysty, 0.75).
regula_fuzzy(r_fz_015, singapur, wysokosc_budynkow, gorzysty, 0.68).
regula_fuzzy(r_fz_016, poludniowa_afryka, suchosc_klimatu, pagorkowaty, 0.55).
regula_fuzzy(r_fz_017, poludniowa_afryka, gestosc_zabudowy, pagorkowaty, 0.48).
regula_fuzzy(r_fz_018, korea_poludniowa, gestosc_zabudowy, gorzysty, 0.70).
regula_fuzzy(r_fz_019, korea_poludniowa, wysokosc_budynkow, gorzysty, 0.65).
regula_fuzzy(r_fz_020, sri_lanka, suchosc_klimatu, plaski, 0.70).
regula_fuzzy(r_fz_021, sri_lanka, wysokosc_roslinnosci, gorzysty, 0.58).
regula_fuzzy(r_fz_022, zjednoczone_emiraty_arabskie, suchosc_klimatu, gorzysty, 0.78).
regula_fuzzy(r_fz_023, zjednoczone_emiraty_arabskie, gorzystosc_terenu, plaski, 0.62).
regula_fuzzy(r_fz_024, zjednoczone_emiraty_arabskie, wysokosc_budynkow, gorzysty, 0.60).
regula_fuzzy(r_fz_025, wielka_brytania, zachmurzenie, gorzysty, 0.60).
regula_fuzzy(r_fz_026, wielka_brytania, suchosc_klimatu, plaski, 0.55).
regula_fuzzy(r_fz_027, wielka_brytania, zageszczenie_lasu, pagorkowaty, 0.45).
regula_fuzzy(r_fz_028, usa, droga_szeroka, gorzysty, 0.58).
regula_fuzzy(r_fz_029, usa, jakosc_nawierzchni, pagorkowaty, 0.50).
regula_fuzzy(r_fz_030, usa, suchosc_klimatu, plaski, 0.52).
% =========================
% 6) Weta (warunki wykluczające)
% =========================
% weto(Kraj, cecha_enum(F, WymaganaWartosc), Prog) — konflikt gdy odpowiedź inna niż W.
% weto_zakaz(Kraj, Cecha, ZabronionaWartosc, Prog) — konflikt gdy użytkownik wybrał tę wartość.
% polkula — wyłącznie w weto (brak reguł CF/rozmytych); pomija kraje między zwrotnikami.

% --- Weta: strona ruchu (każdy aktywny kraj) ---
weto(argentyna, cecha_enum(strona_ruchu, prawostronny), 0.75).
weto(australia, cecha_enum(strona_ruchu, lewostronny), 0.75).
weto(brazylia, cecha_enum(strona_ruchu, prawostronny), 0.75).
weto(rosja, cecha_enum(strona_ruchu, prawostronny), 0.75).
weto(senegal, cecha_enum(strona_ruchu, prawostronny), 0.75).
weto(singapur, cecha_enum(strona_ruchu, lewostronny), 0.75).
weto(poludniowa_afryka, cecha_enum(strona_ruchu, lewostronny), 0.75).
weto(korea_poludniowa, cecha_enum(strona_ruchu, prawostronny), 0.75).
weto(sri_lanka, cecha_enum(strona_ruchu, lewostronny), 0.75).
weto(zjednoczone_emiraty_arabskie, cecha_enum(strona_ruchu, prawostronny), 0.75).
weto(wielka_brytania, cecha_enum(strona_ruchu, lewostronny), 0.75).
weto(usa, cecha_enum(strona_ruchu, prawostronny), 0.75).

% --- Weta: półkula (kraje poza pasem międzyzwrotnikowym) ---
% Bez weta półkuli: brazylia, senegal, singapur, sri_lanka (obszar między zwrotnikami).
weto(argentyna, cecha_enum(polkula, pld), 0.75).
weto(australia, cecha_enum(polkula, pld), 0.75).
weto(rosja, cecha_enum(polkula, pln), 0.75).
weto(poludniowa_afryka, cecha_enum(polkula, pld), 0.75).
weto(korea_poludniowa, cecha_enum(polkula, pln), 0.75).
weto(zjednoczone_emiraty_arabskie, cecha_enum(polkula, pln), 0.75).
weto(wielka_brytania, cecha_enum(polkula, pln), 0.75).
weto(usa, cecha_enum(polkula, pln), 0.75).
weto(brazylia, cecha_enum(typ_biomu, borealny), 0.80).
weto(zjednoczone_emiraty_arabskie, cecha_enum(obecnosc_sniegu, brak), 0.75).
weto(usa, cecha_enum(kolor_tylnej_tablicy, zolty), 0.75).

% --- Weta: znaki drogowe ---
weto_zakaz(australia, kolor_tylnej_tablicy, zolty, 0.80).
weto_zakaz(australia, kolor_znaku_ograniczenia_predkosci, z_czerwona_obwodka, 0.75).
weto_zakaz(poludniowa_afryka, kolor_znaku_ograniczenia_predkosci, z_czerwona_obwodka, 0.80).
weto_zakaz(wielka_brytania, kolor_znaku_ograniczenia_predkosci, z_czerwona_obwodka, 0.80).
% Weto językowe: jezyk_urzedowy_kraju/2 + inference_engine:language_zakaz_conflict_strength/3
% =========================
% 7)