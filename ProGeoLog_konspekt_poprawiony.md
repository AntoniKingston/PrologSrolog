# ProGeoLog - poprawiony konspekt zgodny z wymaganiami

## 1. Cel projektu

System ekspertowy `ProGeoLog` wspomaga identyfikację kraju na podstawie obserwacji sceny Street View.
Rozwiązanie realizuje kontekstowy dialog z użytkownikiem i dochodzi do konkluzji przez reguły produkcji, a nie przez selekcję statycznych faktów.

## 2. Architektura (4 wymagane komponenty)

Projekt jest modularny i rozdziela sterowanie, wiedzę i dane przedmiotowe:

1. **Interfejs (Python + PyQt)**  
   - prezentuje pytania i formy odpowiedzi adekwatne do typu cechy,  
   - przekazuje odpowiedzi do silnika Prolog,  
   - nie przechowuje danych dziedzinowych jako logiki decyzyjnej.

2. **Baza danych i wiedzy (Prolog)**  
   - fakty dziedzinowe i reguły produkcji,  
   - reguły kontekstowe do wyboru kolejnych pytań,  
   - reguły konkluzji dla krajów.

3. **Mechanizm wnioskowania rozmytego (Prolog + wywołania z Python)**  
   - rozmywanie, reguły Mamdaniego, agregacja i wyostrzanie,  
   - wynik rozmyty jako dodatkowy dowód dla kraju.

4. **Moduł znajdowania reguł minimalnych (Prolog/Python)**  
   - analiza tablicy decyzyjnej i reduktów,  
   - generowanie i druk reguł minimalnych oraz rdzenia (core),  
   - działa jako oddzielny moduł diagnostyczno-optymalizacyjny.

## 3. Podział odpowiedzialności zespołu (4 osoby)

- Osoba A: baza wiedzy (model pojęć, reguły dziedzinowe, konkluzje).
- Osoba B: wnioskowanie i interfejs (dialog kontekstowy, integracja PyQt-Prolog).
- Osoba C: wnioskowanie przybliżone (CF/MYCIN, konflikty i normalizacja).
- Osoba D: wnioskowanie rozmyte (zmienne lingwistyczne, defuzyfikacja).

Każda osoba zna podstawy teoretyczne wszystkich modułów.

## 4. Reprezentacja wiedzy i spójność danych

### 4.1 Zasady nazewnictwa i typów

- Wszystkie atrybuty i wartości są symboliczne i spójne (`ruch_lewostronny`, `tablica_zolte_tyl`).
- Wartości liczbowe pozostają liczbowe (`0.0..1.0`), symbole pozostają symbolami.
- Te same identyfikatory są używane w: pytaniach, faktach odpowiedzi, regułach i wyjaśnieniach.

### 4.2 Fakty i reguły

- Fakty dziedzinowe opisują cechy i parametry reguł.
- Konkluzje końcowe **nie są statycznymi faktami**; są wyprowadzane przez reguły:
  - `hipoteza(Kraj, Pewnosc)` powstaje dynamicznie,
  - `wynik_koncowy/2` wybiera najlepszą hipotezę.

## 5. Wymagania formalne i sposób spełnienia

1. **System piszemy w Prologu** - baza wiedzy, reguły i inferencja są w Prologu.
2. **Modularność i separacja** - interfejs oddzielony od wiedzy i danych.
3. **Reguły minimalne jako oddzielny moduł** - dedykowany komponent.
4. **Min. ok. 100 reguł produkcji** - plan:
   - 70-90 reguł krajowych (przesłanki -> hipoteza),
   - 15-25 reguł kontekstowych pytań,
   - 10-20 reguł integrujących evidence (CF/fuzzy/weto),
   - razem 100+ reguł biorących udział we wnioskowaniu/dialogu.
5. **Ograniczone fakty sterujące** - tylko do etapów (np. inicjalizacja), bez "sztucznej kontroli".
6. **Kontekst w dialogu** - kolejne pytanie zależy od wcześniejszych odpowiedzi i aktywnych hipotez.
7. **Spójna reprezentacja danych** - jeden słownik pojęć.
8. **Rozwiązania końcowe nie jako fakty** - tylko reguły i konstrukcja dynamiczna.
9. **Naturalna forma odpowiedzi w UI** - radio, checkbox, suwak; bez nadużywania list rozwijanych.

## 6. Dialog kontekstowy (ważna poprawka)

W każdej iteracji wybór pytania opiera się na:
- nierozróżnionych jeszcze parach hipotez,
- atrybutach o najwyższej mocy separacyjnej,
- dostępności odpowiedzi użytkownika (`nie wiem` nie blokuje procesu).

To zapewnia wielościeżkowe dochodzenie do wniosku zamiast sztywnego algorytmu krok po kroku.

## 7. Mechanizm hybrydowy

### 7.1 Część przybliżona (CF)
- reguły z wagami dla cech binarnych i częściowo pewnych,
- łączenie dowodów dodatnich/ujemnych,
- weto dla silnie sprzecznych sygnałów.

### 7.2 Część rozmyta
- zmienne lingwistyczne (np. górzystość, wilgotność, zurbanizowanie),
- funkcje przynależności (trójkąt/trapez),
- Mamdani + środek ciężkości.

### 7.3 Integracja
- wynik końcowy kraju = agregacja: `CF + fuzzy + reguły kontekstowe - weta`.

## 8. Plan implementacji

1. Słownik pojęć i typów danych.
2. Szkielet modułów Prolog (`knowledge`, `inference`, `minimal_rules`, `dialog`).
3. Implementacja pytań kontekstowych.
4. Implementacja reguł krajowych (wersja bazowa 40-50 reguł).
5. Rozszerzenie do 100+ reguł.
6. Moduł reduktów i reguł minimalnych.
7. Integracja z PyQt przez `pyswip`.
8. Walidacja: testy scenariuszowe i test spójności nazw.

## 9. Co było ryzykowne w poprzedniej wersji i co poprawiono

- Doprecyzowano formalnie obecność wszystkich 4 komponentów wymaganych przez prowadzącą.
- Dopisano jawny plan osiągnięcia minimum ~100 reguł produkcji.
- Wzmocniono wymóg dialogu kontekstowego (dynamiczny dobór pytań).
- Uporządkowano rozdział "konkluzje nie są faktami statycznymi".
- Dodano ograniczenia dot. faktów sterujących.

## 10. Artefakty do oddania

- `knowledge_base.pl` - fakty dziedzinowe i reguły produkcji.
- `inference_engine.pl` - ewaluacja CF/fuzzy, wybór hipotez.
- `minimal_rules.pl` - redukty i reguły minimalne.
- `dialog_strategy.pl` - wybór pytań kontekstowych.
- `gui_app.py` - interfejs PyQt i most do Prolog.
- `tests/` - scenariusze i testy spójności.
