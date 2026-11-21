# Spec Delta

## ADDED Requirements

### Requirement: Alert serii wymagających działania
Lista serii SHALL pokazywać czerwony wykrzyknik obok numeru aktywnej serii, której następne działanie ma termin dziś lub wcześniej. Alert SHALL wskazywać działanie i jego termin w podpowiedzi oraz etykiecie dostępności.

#### Scenario: Działanie przypada dziś
- **GIVEN** aktywna seria ma następne działanie zaplanowane na bieżący dzień
- **WHEN** użytkownik przegląda listę serii
- **THEN** obok numeru serii widzi czerwony wykrzyknik z opisem działania i terminu

#### Scenario: Działanie jest po terminie
- **GIVEN** aktywna seria ma następne działanie zaplanowane przed bieżącym dniem
- **WHEN** użytkownik przegląda listę serii
- **THEN** obok numeru serii widzi czerwony wykrzyknik z opisem zaległego działania i terminu

#### Scenario: Działanie przypada w przyszłości
- **GIVEN** aktywna seria ma następne działanie zaplanowane po bieżącym dniu
- **WHEN** użytkownik przegląda listę serii
- **THEN** przy serii nie ma czerwonego wykrzyknika

#### Scenario: Seria bez aktywnego działania
- **GIVEN** seria jest zaplanowana i nie ma rozpoczętego harmonogramu albo jest ukończona
- **WHEN** użytkownik przegląda listę serii
- **THEN** przy serii nie ma czerwonego wykrzyknika

#### Scenario: Powód alertu dostępny bez myszy
- **GIVEN** seria ma czerwony wykrzyknik
- **WHEN** użytkownik przechodzi do niego klawiaturą lub korzysta z czytnika ekranu
- **THEN** otrzymuje tę samą informację o działaniu i terminie co w podpowiedzi
