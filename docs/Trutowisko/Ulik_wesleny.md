# Ulik weselny – zarządzanie stanami i matkami pszczelimi

Widok szczegółowy ulika weselnego na trutowisku służy do precyzyjnego monitorowania cyklu życia, stanów oraz parametrów matki pszczelej.

## Stany ulików weselnych

W systemie BeeLog wyróżniamy 4 główne stany ulików weselnych:

1. **`(B) Bezmatek`** – W uliku nie ma matki ani matecznika.
2. **`(M) Matecznik`** – W uliku znajduje się poddany matecznik.
3. **`(N) Matka nieunasienniona`** – Matka wygryzła się z matecznika lub została poddana jako nieunasienniona; oczekuje na lot godowy i unasiennienie.
4. **`(UNC) Matka unasienniona`** – Matka rozpoczęła czerwienie (pomyślnie unasienniona).

---

## Szczegółowe zasady przechodzenia między stanami i operacje

### 1. Ze stanu `(B) Bezmatek`
- **Poddano matecznik**:
  - Wymaga podania:
    - Rasy i linii matki pszczelej
    - Spodziewanego terminu wygryzienia się matki
  - **Automatyczne obliczenia**: na podstawie terminu wygryzienia system automatycznie wylicza spodziewany termin unasiennienia (+10 dni).
  - Wszystkie informacje są zapisywane w danych ulika oraz w historii zmian.
- **Poddano matkę nieunasiennioną**:
  - Wymaga podania:
    - Rasy i linii matki pszczelej
    - Koloru opalitka (biały, żółty, czerwony, zielony, niebieski, BRAK)
    - Numeru opalitka
    - Terminu wygryzienia się matki
  - **Automatyczne obliczenia**: na podstawie terminu wygryzienia wyliczany jest spodziewany termin unasiennienia (+10 dni).

### 2. Ze stanu `(M) Matecznik`
- **Matka się wygryzła (N)**: Przejście do stanu matki nieunasiennionej.
- **Matecznik się nie wygryzł (B)**: 
  - Resetuje na puste dane o: rasie i linii, kolorze i numerze opalitka oraz datach planowanego wygryzienia i unasiennienia. Ulik wraca do stanu Bezmatek.

### 3. Ze stanów `(N) Matka nieunasienniona` oraz `(UNC) Matka unasienniona`
- **Akcja "Zaopalitkuj"**:
  - Dostępna w stanach (N) oraz (UNC).
  - Pozwala uzupełnić lub zaktualizować:
    - Kolor opalitka (biały, żółty, czerwony, zielony, niebieski)
    - Numer opalitka
  - Dane te są natychmiast zapisywane w historii edycji oraz aktualizują dane ulika.
- **Zmiana stanu / Strutowienie / Odłowienie**:
  - Matka strutowiała / zniknęła (powrót do Bezmatka `B` z resetem danych).
  - Zabieram matkę (odłowienieunasiennionej matki do pasieki towarowej / ula produkcyjnego, powrót do Bezmatka `B`).

---

## Historia zmian stanów

Na dole widoku szczegółowego ulika weselnego znajduje się sekcja **Historii zmian stanów**:
- Wpisy są posortowane od **najnowszego (na górze)** do **najstarszego (na dole)**.
- Każda zmiana zawiera dokładny **timestamp** (datę i godzinę), opis zdarzenia, stan oraz pełny zestaw parametrów matki (rasa/linia, planowane terminy wygryzienia i unasiennienia, obecność, kolor i numer opalitka).
