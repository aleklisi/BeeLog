# OpenSpec: Moduł Wychowu Matek Pszczelich (Queen Rearing Module)

**Wersja:** 1.0.0  
**Status:** Specyfikacja robocza – przed implementacją należy uwzględnić doprecyzowania poniżej  
**Metodyka:** Specification-Driven Development (SDD)  
**Domena:** Zarządzanie pasieką – Hodowla i wychów matek pszczelich  

---

## 1. Przegląd i Cel Modułu

Moduł **Wychowu Matek Pszczelich** służy do pełnego planowania, śledzenia i ewidencjonowania cyklu hodowlanego matek pszczelich w pasiece – od wyboru materiału genetycznego (reproduktorek), przez szczepienie larw w starterach, dojrzewanie mateczników w finisherach, aż po izolację w cieplarce i wygryzienie matek.

### Główne założenia:
* Ścisła kontrola dostępności uli wychowowych (**Starterów** i **Finisherów**) zapobiegająca kolizjom serii.
* Automatyczne wyliczanie harmonogramu prac hodowlanych na podstawie czasu zaszczepienia oraz ustawień użytkownika.
* Priorytetyzacja operacyjna na liście serii (alerty czasowe i sortowanie według pilności).
* Podział interfejsu na zarządzanie zasobami hodowlanymi oraz operacyjne prowadzenie serii (widok Master-Detail).

---

## 2. Ustawienia Modułu (`ModuleSettings`)

System udostępnia użytkownikowi sekcję konfiguracji domyślnych parametrów hodowlanych. Wartości są ustawieniami użytkownika i służą do inicjowania nowych serii; zmiana ustawień nie zmienia harmonogramów już rozpoczętych serii.

| Parametr | Klucz | Typ | Wartość domyślna | Zakres / Walidacja | Opis |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Domyślna liczba larw | `defaultLarvaeCount` | `Integer` | `24` | `> 0` | Domyślna liczba miseczek na ramce hodowlanej podpowiadana przy szczepieniu. |
| Czas pobytu w starterze | `daysInStarter` | `Integer` | `2` | `1 - 10` dni | Liczba dni od zaszczepienia do przełożenia ramki ze startera do finishera. |
| Czas do izolacji (cieplarka) | `daysToIsolation` | `Integer` | `10` | `> daysInStarter` | Liczba dni od zaszczepienia do zamknięcia mateczników w lokówkach/cieplarce. |
| Czas do wygryzienia | `daysToEmergence` | `Integer` | `11` | `>= daysToIsolation` | Szacowana liczba dni od zaszczepienia larwy jednodniowej do wygryzienia matki. |

---

## 3. Model Domenowy i Encje (Data Model)

### 3.1. Reproduktorka (`BreederQueen`)
Matka pszczela stanowiąca źródło larw do szczepienia.
* `id` (`String`, Firestore document ID): Unikalny identyfikator dokumentu.
* `breedAndLine` (`String`, Required): Nazwa rasy i linii hodowlanej (np. *Carnica / Gema*, *Buckfast / B43*).
* `markingColor` (`Enum`, Required): Kolor opalitka (`BIALY`, `ZOLTY`, `CZERWONY`, `ZIELONY`, `NIEBIESKI`).
* `markingCode` (`String`, Required): Numer lub napis na opalitku (np. `15`, `A-12`).
* `hiveNumber` (`String`, Required): Numer ula, w którym znajduje się reproduktorka.

### 3.2. Starter (`StarterColony`)
Rodzina pszczela służąca do przyjęcia zaszczepionych larw.
* `id` (`String`, Firestore document ID): Unikalny identyfikator dokumentu.
* `hiveNumber` (`String`, Required): Numer ula startera.
* `seriesCounter` (`Integer`, Default: `0`): Licznik zrealizowanych serii w tym starterze.
* `status` (`Enum`, Default: `PUSTY`): Stan dostępności (`PUSTY`, `ZAJETY`).

### 3.3. Finisher (`FinisherColony`)
Rodzina pszczela służąca do pielęgnacji i wygrzewania przyjętych mateczników.
* `id` (`String`, Firestore document ID): Unikalny identyfikator dokumentu.
* `hiveNumber` (`String`, Required): Numer ula finishera.
* `seriesCounter` (`Integer`, Default: `0`): Licznik zrealizowanych serii w tym finisherze.
* `status` (`Enum`, Default: `PUSTY`): Stan dostępności (`PUSTY`, `ZAJETY`).

### 3.4. Seria Wychowu (`RearingBatch`)
Główna encja agregująca cykl hodowlany.
* `id` (`String`, Firestore document ID): Unikalny identyfikator dokumentu.
* `batchNumber` (`String`, Unique, Auto-generated): Kolejny numer serii nadawany automatycznie w ramach sezonu (np. `2026/01`, `2026/02`).
* `status` (`Enum`, Default: `ZAPLANOWANA`): Aktualny etap cyklu życia serii:
  * `ZAPLANOWANA`
  * `W_STARTERZE`
  * `W_FINISHERZE`
  * `W_CIEPLARCE`
  * `ZAKONCZONA`
* `reproducerId` (`String`, Nullable w stanie `ZAPLANOWANA`, wymagany od `W_STARTERZE`): ID wybranej reproduktorki.
* `starterId` (`String`, Nullable): ID przypisanego startera.
* `finisherId` (`String`, Nullable): ID przypisanego finishera.
* `larvaeCount` (`Integer`, Nullable): Liczba zaszczepionych larw / miseczek.
* `startDateTime` (`DateTime`, Nullable w stanie `ZAPLANOWANA`, wymagany od `W_STARTERZE`): Dokładna data, godzina i minuta przekładania larw.
* `timeZone` (`String`, IANA, Nullable w stanie `ZAPLANOWANA`, wymagany od `W_STARTERZE`): Strefa czasowa używana do wyliczania lokalnych terminów serii.
* `scheduleDaysInStarter`, `scheduleDaysToIsolation`, `scheduleDaysToEmergence` (`Integer`, Nullable): Kopia wartości ustawień użytych przy rozpoczęciu serii. Zachowuje harmonogram serii niezależnie od późniejszych zmian ustawień użytkownika.
* **Terminy wyliczane automatycznie** (na podstawie `startDateTime` i zapisanych wartości `scheduleDays...`):
  * `transferToFinisherDate` (`DateTime`): `startDateTime + scheduleDaysInStarter`.
  * `isolationDate` (`DateTime`): `startDateTime + scheduleDaysToIsolation`.
  * `emergenceDate` (`DateTime`): `startDateTime + scheduleDaysToEmergence`.
* `acceptedCellsCount` (`Integer`, Nullable): Liczba przyjętych mateczników (uzupełniana przy ocenie startera).
* `incubatorBarNumber` (`String`, Nullable): Numer listwy w cieplarce (uzupełniany przy przejściu do cieplarki).
* `emergedQueensCount` (`Integer`, Nullable): Liczba wygryzionych matek (wymagana przy zakończeniu serii, niezależnie od użycia cieplarki; pusta przy zakończeniu z zerową liczbą przyjętych mateczników).

---

## 4. Reguły Biznesowe i Niezmienniki (Business Rules & Invariants)

### RB-01: Blokowanie i zwalnianie zasobów (Starter / Finisher)
1. **Dostępność:** Do serii można przypisać **wyłącznie** Starter lub Finisher o statusie `PUSTY`. Sprawdzenie dostępności, przypisanie zasobu i zmiana jego statusu muszą być wykonane atomowo, aby dwie równoczesne operacje nie przypisały tego samego ula do różnych aktywnych serii.
2. **Filtrowanie UI:** Listy wyboru starterów i finisherów w formularzach muszą prezentować tylko obiekty ze statusem `PUSTY` (obiekty `ZAJETY` są ukryte lub zablokowane z informacją o aktywnej serii).
3. **Zajęcie Startera:** Przejście serii w stan `W_STARTERZE` zmienia status wybranego Startera na `ZAJETY`.
4. **Zwolnienie Startera i zajęcie Finishera:** Przejście serii ze stanu `W_STARTERZE` w stan `W_FINISHERZE` zmienia status startera na `PUSTY` i inkrementuje jego `seriesCounter`, a status wybranego finishera zmienia na `ZAJETY`. Jeśli `acceptedCellsCount` wynosi `0`, zakończenie serii zwalnia starter i inkrementuje jego licznik, bez przypisywania finishera.
5. **Zwolnienie Finishera:** Opuszczenie stanu `W_FINISHERZE` (zarówno przez przejście do `W_CIEPLARCE`, jak i bezpośrednie `ZAKONCZONA`) zmienia status finishera na `PUSTY` oraz inkrementuje jego `seriesCounter`.
6. **Usunięcie aktywnej serii:** Usunięcie serii będącej w stanie `W_STARTERZE` lub `W_FINISHERZE` musi atomowo przywrócić status `PUSTY` przypisanemu do niej ulowi. Usunięcie nie zwiększa `seriesCounter`; licznik zwiększa się wyłącznie po normalnym zakończeniu etapu korzystania z zasobu.

### RB-02: Automatyczna numeracja serii
* Numer ma format `RRRR/NN` i jest unikalny w obrębie konta użytkownika. Jest nadawany atomowo. Rok oznacza rok kalendarzowy w strefie czasowej użytkownika; numeracja zaczyna się od `01` każdego 1 stycznia. Usunięte numery nie są ponownie używane.

### RB-03: Wyliczanie harmonogramu
* Przy rozpoczęciu serii wartości czasów z ustawień użytkownika są kopiowane do serii. Zmiana `startDateTime` przelicza terminy na podstawie tych kopii. Późniejsza zmiana ustawień wpływa wyłącznie na nowe serie. Dodanie lub zmiana danych harmonogramu istniejącej serii wymaga jawnej edycji tej serii.
* Dodanie liczby dni zachowuje lokalną godzinę rozpoczęcia serii i używa strefy zapisanej w `timeZone`. Instancje czasu są zapisywane jednoznacznie (UTC), a prezentowane w zapisanej strefie serii.

### RB-04: Walidacja danych i przejść
* `larvaeCount` musi być liczbą całkowitą większą od zera. `acceptedCellsCount` musi należeć do przedziału od `0` do `larvaeCount`. Gdy wartość wynosi `0`, serię można zakończyć bez przypisywania finishera; starter zostaje zwolniony. Gdy wartość jest większa od `0`, wymagane jest przypisanie finishera. `emergedQueensCount` musi należeć do przedziału od `0` do `acceptedCellsCount`.
* Przejścia są dozwolone tylko w kolejności opisanej w maszynie stanów. Wymagane pola akcji muszą być zwalidowane przed zmianą stanu i zasobów.
* Usunięcie startera lub finishera przypisanego do aktywnej serii jest zablokowane. Reproduktorki powiązanej z serią nie można usunąć; można ją oznaczyć jako nieaktywną, aby nie była dostępna dla nowych serii.

---

## 5. Maszyna Stanów Serii Wychowu (State Machine)

```text
[Nowa Seria] 
     │
     ▼
( ZAPLANOWANA )
     │
     ├─── Akcja: "Przekładanie larw" 
     │    [Formularz: Reproduktorka, Liczba larw (domyślnie z ust.), Starter (PUSTY), Data/Czas (domyślnie TERAZ)]
     │    [Efekt: Starter -> ZAJETY, wyliczenie dat]
     ▼
( W_STARTERZE )
     │
     ├─── Akcja: "Przekładanie ramki hodowlanej do finishera"
     │    [Formularz: Liczba przyjętych mateczników, Finisher (PUSTY)]
     │    [Efekt: Starter -> PUSTY, Finisher -> ZAJETY]
     ▼
( W_FINISHERZE )
     │
     ├──────────────────────────────┐
     │ (Ścieżka A: Cieplarka)       │ (Ścieżka B: Bezpośrednio do uli)
     ▼                              ▼
Akcja: "Przekładanie do cieplarki"  Akcja: "Zakończ serię"
[Formularz: Numer listwy]           [Formularz: Liczba wygryzionych matek]
[Efekt: Finisher -> PUSTY]          │
     │                              │
     ▼                              │
( W_CIEPLARCE )                     │
     │                              │
     ├─── Akcja: "Wygryzły się"     │
     │    [Formularz: Ile matek?]   │
     ▼                              ▼
(         ZAKONCZONA                )
```

Jeżeli przy ocenie startera `acceptedCellsCount` wynosi `0`, użytkownik może zakończyć serię bez etapu finishera. Starter zostaje zwolniony, seria przechodzi do `ZAKONCZONA`, a `finisherId`, `incubatorBarNumber` i `emergedQueensCount` pozostają puste. Przejście ze startera do finishera wymaga `acceptedCellsCount > 0`.

---

## 6. Wymagania Interfejsu Użytkownika (UI / UX Specification)

### 6.1. Podział Panelu Głównego
Panel modułu hodowlanego podzielony jest na **2 wyraźne sekcje**:
1. **Sekcja 1: Zasoby Hodowlane** – zarządzanie (CRUD: Dodawanie, Edycja, Usuwanie) dla list:
   * Reproduktorek (z podglądem rasy/linii, koloru i numeru opalitka oraz numeru ula).
   * Starterów (numer ula, licznik serii, badge statusu `PUSTY` / `ZAJĘTY`).
   * Finisherów (numer ula, licznik serii, badge statusu `PUSTY` / `ZAJĘTY`).
2. **Sekcja 2: Zarządzanie Seriami Wychowu** – operacyjna lista serii oraz przycisk tworzenia nowej serii (`ZAPLANOWANA`).

### 6.2. Widok Listy Serii: Oś Czasu (Timeline) i Alerty
Każdy element na liście serii prezentuje:
* Numer serii i aktualny status.
* **Wizualną Oś Czasu (Timeline):** Krokowy pasek postępu pokazujący etapy (`Start` $\rightarrow$ `Finisher` $\rightarrow$ `Cieplarka` $\rightarrow$ `Wygryzienie`) wraz z oczekiwanymi terminami oraz aktualnym położeniem serii.
* **Wskaźnik Czasu / Alert (Badge):** Obliczany dynamicznie dla serii rozpoczętych i niezakończonych (`W_STARTERZE`, `W_FINISHERZE`, `W_CIEPLARCE`) na podstawie różnicy $\Delta t = \text{TerminNastępnejAkcji} - \text{Teraz}$:
  * **Po terminie ($\Delta t < 0$):** Kolor **CZERWONY** + ikona **czerwonego wykrzyknika (`!`)** (np. *„Po terminie! Wymagana akcja”*).
  * **Pilne ($0 \le \Delta t \le 24\text{h}$ / 1 dzień lub mniej):** Kolor **ŻÓŁTY** (np. *„Wymagana akcja za 1 dzień”* / *„za 8 godz.”*).
  * **Bezpieczne ($\Delta t > 24\text{h}$ / więcej niż 1 dzień):** Kolor **ZIELONY** (np. *„Wymagana akcja za 3 dni”*).

Termin następnej akcji zależy od stanu: `W_STARTERZE` – `transferToFinisherDate`, `W_FINISHERZE` – `isolationDate`, `W_CIEPLARCE` – `emergenceDate`. Odliczanie używa dokładnego czasu; etykieta dni zaokrągla pozostały czas w górę, a dla mniej niż 24 godzin pokazuje godziny. Dokładnie w terminie alert ma status pilny (żółty).

### 6.3. Reguła Sortowania Listy Serii
Lista serii jest domyślnie sortowana według następującego priorytetu (od góry do dołu):
1. **Grupa 1 (Najwyżej):** Serie w toku **po terminie** (od największego opóźnienia).
2. **Grupa 2:** Serie w toku **przed terminem**, posortowane rosnąco po czasie pozostałym do następnej akcji (najpierw żółte $\le 1$ dzień, potem zielone $> 1$ dzień).
3. **Grupa 3:** Serie w stanie `ZAPLANOWANA`.
4. **Grupa 4 (Najniżej):** Serie w stanie `ZAKONCZONA`.

W grupach z takim samym priorytetem serie są sortowane rosnąco po terminie następnej akcji, a następnie po `batchNumber`.

### 6.4. Widok Szczegółów / Edycji Serii (Master-Detail)
Kliknięcie dowolnej serii na liście otwiera jej widok szczegółowy, w którym użytkownik może:
* Podejrzeć pełne powiązania (reproduktorka, starter, finisher, listwa w cieplarce) i metryki (liczba larw, przyjęć, wygryzień).
* Wykonać **akcję przejścia do kolejnego stanu** (przyciski kontekstowe zależne od obecnego stanu).
* Edytować wprowadzone wcześniej dane i uzupełniać brakujące informacje.
* Usunąć serię (z zachowaniem reguły RB-01 pkt 6).

---

## 7. Scenariusze Akceptacyjne (Gherkin / BDD)

```gherkin
Feature: Zarządzanie cyklem życia serii wychowu matek pszczelich

  Background:
    Given w ustawieniach modułu domyślna liczba larw wynosi 24
    And czas w starterze wynosi 2 dni, do izolacji 10 dni, do wygryzienia 11 dni
    And strefa czasowa użytkownika to "Europe/Warsaw"
    And istnieje reproduktorka "Carnica Gema" w ulu "U-1"
    And istnieje starter "S-1" o statusie "PUSTY"
    And istnieje finisher "F-1" o statusie "PUSTY"

  Scenario: Pełny cykl serii z wykorzystaniem cieplarki
    When użytkownik tworzy nową serię wychowu
    Then seria otrzymuje automatyczny numer i ma stan "ZAPLANOWANA"

    When użytkownik uruchamia akcję "Przekładanie larw" dla tej serii
    And wybiera reproduktorkę "Carnica Gema", starter "S-1", akceptuje 24 larwy oraz datę "2026-05-10 10:00"
    Then seria zmienia stan na "W_STARTERZE"
    And starter "S-1" zmienia status na "ZAJETY"
    And wyliczona data przełożenia do finishera to "2026-05-12 10:00"
    And wyliczona data izolacji to "2026-05-20 10:00"
    And wyliczona data wygryzienia to "2026-05-21 10:00"

    When użytkownik uruchamia akcję "Przekładanie ramki hodowlanej do finishera"
    And wpisuje 20 przyjętych mateczników oraz wybiera finisher "F-1"
    Then seria zmienia stan na "W_FINISHERZE"
    And starter "S-1" zmienia status na "PUSTY"
    And finisher "F-1" zmienia status na "ZAJETY"

    When użytkownik uruchamia akcję "Przekładanie do cieplarki" i podaje numer listwy "L-4"
    Then seria zmienia stan na "W_CIEPLARCE"
    And finisher "F-1" zmienia status na "PUSTY"
    And seria ma zapisany numer listwy "L-4"

    When użytkownik uruchamia akcję "Wygryzły się" i podaje liczbę 19 matek
    Then seria zmienia stan na "ZAKONCZONA"
    And liczba wygryzionych matek wynosi 19

  Scenario: Blokada wyboru zajętego startera
    Given starter "S-1" ma status "ZAJETY" przez inną serię
    When użytkownik otwiera formularz "Przekładanie larw" dla nowej serii
    Then starter "S-1" nie jest dostępny do wyboru

  Scenario: Alert o przekroczonym terminie i sortowanie listy
    Given seria "2026/01" jest w stanie "W_STARTERZE" i termin przełożenia do finishera minął 3 godziny temu
    And seria "2026/02" jest w stanie "W_STARTERZE" i do przełożenia zostało 12 godzin
    And seria "2026/03" jest w stanie "W_STARTERZE" i do przełożenia zostały 3 dni
    And seria "2026/04" ma stan "ZAPLANOWANA"
    When użytkownik wyświetla listę serii
    Then kolejność na liście to: "2026/01", "2026/02", "2026/03", "2026/04"
    And przy serii "2026/01" wyświetla się czerwony wykrzyknik
    And przy serii "2026/02" wyświetla się żółty status "Wymagana akcja za 12 godz."
    And przy serii "2026/03" wyświetla się zielony status "Wymagana akcja za 3 dni"

  Scenario: Zakończenie bez cieplarki
    Given seria jest w stanie "W_FINISHERZE" i ma 20 przyjętych mateczników
    When użytkownik wybiera "Zakończ serię" i podaje liczbę 18 wygryzionych matek
    Then seria zmienia stan na "ZAKONCZONA"
    And finisher zmienia status na "PUSTY"
    And liczba wygryzionych matek wynosi 18
    And numer listwy w cieplarce pozostaje pusty

  Scenario: Zakończenie serii bez przyjętych mateczników
    Given seria jest w stanie "W_STARTERZE"
    When użytkownik zapisuje 0 przyjętych mateczników i kończy serię
    Then seria zmienia stan na "ZAKONCZONA"
    And starter zmienia status na "PUSTY"
    And licznik serii startera zwiększa się o 1
    And finisher nie zostaje przypisany
```

---

## 8. Nawigacja główna i menu widoków (OpenSpec)

### Cel

Główny widok aplikacji udostępnia kompaktowe menu otwierane przyciskiem z ikoną trzech poziomych kresek (☰). Pozycje modułów opcjonalnych zależą od ustawień zalogowanego użytkownika.

### Wymagania

#### Requirement: Menu nawigacji głównej
Aplikacja SHALL udostępniać w głównym widoku przycisk menu z ikoną trzech poziomych kresek. Kliknięcie przycisku SHALL otwierać lub zamykać listę nawigacji.

#### Requirement: Widoki opcjonalne konfigurowane przez użytkownika
Aplikacja SHALL pokazywać pozycje modułów opcjonalnych tylko wtedy, gdy są włączone w ustawieniach zalogowanego użytkownika. Ustawienia widoczności SHALL być zapisywane i odczytywane dla tego użytkownika.

Moduły opcjonalne:

- **Wychów matek** – widok pojawi się po udostępnieniu modułu i włączeniu jego opcji w ustawieniach.
- **Trutowiska** – widoczne, gdy opcja „Trutowiska” jest włączona.
- **Pasieki towarowe** – widoczne, gdy opcja „Pasieki towarowe” jest włączona.

#### Requirement: Stałe pozycje menu
Aplikacja SHALL zawsze wyświetlać pozycje **Ustawienia** i **Wyloguj**, niezależnie od konfiguracji modułów.

#### Requirement: Nawigacja i dostępność
Wybranie pozycji SHALL otwierać odpowiadający jej widok lub uruchamiać istniejący przepływ wylogowania. Po wyłączeniu oglądanego modułu aplikacja SHALL przejść do innego dostępnego widoku lub ustawień. Przycisk menu SHALL mieć dostępną nazwę i stan otwarcia; menu SHALL być obsługiwane klawiaturą i dotykiem.

### Scenariusze akceptacyjne

```gherkin
Feature: Menu główne i widoczność modułów

  Scenario: Menu pokazuje włączone moduły i pozycje stałe
    Given trutowiska i pasieki towarowe są włączone
    And wychów matek jest wyłączony
    When użytkownik otwiera menu
    Then widzi pozycje "Trutowiska", "Pasieki towarowe", "Ustawienia" i "Wyloguj"
    And nie widzi pozycji "Wychów matek"

  Scenario: Ustawienia pozostają dostępne bez modułów
    Given wszystkie moduły opcjonalne są wyłączone
    When użytkownik otwiera menu
    Then nadal widzi pozycje "Ustawienia" i "Wyloguj"

  Scenario: Wylogowanie z menu
    When użytkownik wybiera "Wyloguj"
    Then aplikacja uruchamia przepływ wylogowania
```

---

## 9. Osobne widoki trutowisk i pasiek towarowych (OpenSpec)

### Cel

Trutowiska i pasieki towarowe są dwoma niezależnymi widokami głównymi, każdy z własną pozycją w menu i listą pasiek właściwego typu.

### Wymagania

#### Requirement: Rozdzielone widoki główne
Aplikacja SHALL udostępniać osobne widoki **Trutowiska** i **Pasieki towarowe**. Widok trutowisk SHALL pokazywać tylko pasieki typu `trutowisko`; widok pasiek towarowych SHALL pokazywać tylko pasieki typu `towarowe`. Każdy widok SHALL umożliwiać przeglądanie listy i otwieranie szczegółów pasieki.

#### Requirement: Niezależna nawigacja i konfiguracja
Menu SHALL zawierać osobną pozycję dla każdego z tych widoków, jeśli odpowiednia opcja jest włączona w ustawieniach. Użytkownik SHALL móc włączać i wyłączać widoki niezależnie. Wyłączenie jednego widoku SHALL nie zmieniać ustawienia drugiego ani usuwać jego danych.

#### Requirement: Tworzenie pasieki z właściwego widoku
Utworzenie pasieki z widoku trutowisk SHALL przypisać typ `trutowisko`; utworzenie jej z widoku pasiek towarowych SHALL przypisać typ `towarowe`.

### Scenariusze akceptacyjne

```gherkin
Feature: Oddzielne widoki typów pasiek

  Scenario: Nawigacja do osobnych widoków
    Given oba typy widoków są włączone
    When użytkownik wybiera "Trutowiska"
    Then widzi wyłącznie pasieki typu "trutowisko"
    When użytkownik wybiera "Pasieki towarowe"
    Then widzi wyłącznie pasieki typu "towarowe"

  Scenario: Tworzenie pasieki z właściwego widoku
    When użytkownik tworzy pasiekę z widoku "Trutowiska"
    Then nowa pasieka ma typ "trutowisko"
    When użytkownik tworzy pasiekę z widoku "Pasieki towarowe"
    Then nowa pasieka ma typ "towarowe"

  Scenario: Niezależne wyłączenie widoku
    Given oba widoki są włączone
    When użytkownik wyłącza trutowiska
    Then pozycja "Trutowiska" znika z menu
    And pozycja "Pasieki towarowe" pozostaje widoczna
    And dane trutowisk pozostają zachowane
```
