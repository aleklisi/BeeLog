# Spec: Kalendarz prac w hodowli matek

## ADDED Requirements

### Requirement: Kalendarz terminów serii hodowlanych
Widok Hodowli matek SHALL udostępniać podwidok kalendarza prezentujący terminy etapów serii zaplanowanych i aktywnych, wyliczone z ich zapisanych harmonogramów. Wydarzenie SHALL wskazywać numer serii i etap oraz prowadzić do szczegółów tej serii.

#### Scenario: Przegląd terminów tygodnia
- **GIVEN** serie mają terminy przekładania, transferu, izolacji lub wygryzienia w wybranym tygodniu
- **WHEN** użytkownik otwiera tydzień w kalendarzu
- **THEN** każdy przypadający w nim termin jest pokazany z numerem serii i nazwą etapu

#### Scenario: Przejście do serii
- **WHEN** użytkownik wybiera wydarzenie kalendarza
- **THEN** aplikacja otwiera szczegóły przypisanej serii

#### Scenario: Bieżące i zaległe terminy
- **GIVEN** wydarzenia przypadają dziś lub ich termin minął
- **WHEN** kalendarz jest wyświetlany
- **THEN** wydarzenia bieżące i zaległe są wizualnie odróżnione od przyszłych

#### Scenario: Nawigacja po tygodniach
- **WHEN** użytkownik przechodzi do poprzedniego lub następnego tygodnia
- **THEN** kalendarz pokazuje terminy wybranego zakresu, a powrót do bieżącego tygodnia jest dostępny

#### Scenario: Brak terminów
- **GIVEN** w wybranym zakresie nie ma terminów serii
- **WHEN** użytkownik ogląda kalendarz
- **THEN** widzi czytelny komunikat o braku zaplanowanych prac
