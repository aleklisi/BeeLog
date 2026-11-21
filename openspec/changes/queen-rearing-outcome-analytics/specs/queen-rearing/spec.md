# Spec: Zestawienia skuteczności hodowli matek

## ADDED Requirements

### Requirement: Zakres i agregaty zestawień
Zestawienia SHALL obejmować ukończone serie według daty przełożenia larw (`graftedAt`) oraz wybranego zakresu dat i filtra matki reproduktorki. SHALL pokazywać liczbę serii i sumy dostępnych wartości larw przełożonych, mateczników przyjętych i matek wygryzionych.

#### Scenario: Podsumowanie ukończonych serii
- **GIVEN** ukończone serie zawierają zapisane liczby larw, przyjęć i wygryzień
- **WHEN** użytkownik otwiera zestawienia
- **THEN** widzi liczbę uwzględnionych serii oraz sumy dostępnych wartości

### Requirement: Wskaźniki skuteczności serii
Zestawienia SHALL pokazywać wskaźnik przyjęcia i wygryzień wraz z licznikiem i mianownikiem. Każdy wskaźnik SHALL bazować na dostępnych wartościach z tych samych serii, a brakujące wartości SHALL być pomijane, nie traktowane jako zero.

#### Scenario: Podsumowanie ukończonych serii
- **GIVEN** ukończone serie zawierają zapisane liczby larw, przyjęć i wygryzień
- **WHEN** użytkownik otwiera zestawienia
- **THEN** widzi liczbę serii, sumy tych wartości oraz oba wskaźniki z licznikami i mianownikami

#### Scenario: Filtrowanie zestawienia
- **GIVEN** użytkownik wybiera zakres dat i reproduktorkę
- **WHEN** zestawienie jest wyświetlane
- **THEN** agregaty obejmują wyłącznie ukończone serie spełniające oba filtry, a zakres dat obejmuje wskazane daty graniczne

#### Scenario: Data używana do filtrowania
- **GIVEN** ukończone serie mają różne daty przełożenia larw
- **WHEN** użytkownik ustawia zakres dat zestawienia
- **THEN** seria jest uwzględniana na podstawie tego, czy jej `graftedAt` mieści się w zakresie

#### Scenario: Obliczanie wskaźników
- **GIVEN** zestawienie zawiera serie z zapisanymi liczbami larw przełożonych, przyjętych mateczników i wygryzionych matek
- **WHEN** wskaźniki są wyświetlane
- **THEN** wskaźnik przyjęcia to suma przyjętych mateczników podzielona przez sumę larw przełożonych, a wskaźnik wygryzień to suma wygryzionych matek podzielona przez sumę przyjętych mateczników

#### Scenario: Brak danych do wskaźnika
- **GIVEN** mianownik wskaźnika jest zerowy lub nieznany
- **WHEN** zestawienie jest wyświetlane
- **THEN** wskaźnik pokazuje „brak danych”, a nie wartość zero procent

#### Scenario: Brak wartości w części serii
- **GIVEN** niektóre ukończone serie nie mają zapisanej wartości licznika lub mianownika wskaźnika
- **WHEN** zestawienie jest wyświetlane
- **THEN** brakujące wartości nie zwiększają sum ani nie są traktowane jako zera, a licznik i mianownik wskaźnika obejmują te same serie

#### Scenario: Otworzenie serii ze zestawienia
- **WHEN** użytkownik wybiera serię uwzględnioną w zestawieniu
- **THEN** aplikacja otwiera szczegóły tej serii

#### Scenario: Brak serii w filtrze
- **GIVEN** żadne ukończone serie nie spełniają filtrów
- **WHEN** użytkownik otwiera zestawienie
- **THEN** widzi jawny komunikat o braku danych dla wybranego zakresu
