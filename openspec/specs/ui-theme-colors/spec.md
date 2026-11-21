# ui-theme-colors Specification

## Purpose
Określa zasady kolorystyki interfejsu BeeLog, w tym kontrast w motywach jasnym i ciemnym, wyróżnianie akcji usuwania oraz spójne kolory stanów ulików weselnych.

## Requirements

### Requirement: Zielona paleta interfejsu z wysokim kontrastem tekstu (Light i Dark)
Elementy interfejsu oparte na Tailwind CSS MUSZĄ używać spójnej kolorystyki w odcieniach zieleni (np. `green`, `lime`) w trybie jasnym oraz ciemnym (`dark:`), przy zachowaniu czytelnego kontrastu między tłem a tekstem.

Implementacja MUST spełnić to wymaganie w obu motywach.

#### Scenario: Kontrast przycisków głównych i drugorzędnych w obu motywach
- **WHEN** użytkownik ogląda przyciski główne lub drugorzędne w trybie jasnym lub ciemnym (`dark:`)
- **THEN** tekst na przycisku ma wysoki kontrast względem tła (np. jasny tekst na głębokiej zieleni lub ciemny tekst na jasnym odcieniu `lime`), a stan `hover` oraz `focus` jest wyraźnie widoczny

#### Scenario: Powierzchnie i pola formularzy w spójnej palecie
- **WHEN** użytkownik korzysta z kart, paneli lub pól formularzy w trybie jasnym lub ciemnym
- **THEN** powierzchnie zachowują spójny kontrast z tekstem i etykietami, a aktywne pole formularza (`focus`) wyróżnia się spójnym zielonym/limonkowym obramowaniem lub pierścieniem

### Requirement: Czerwone przyciski akcji usuwania
Przyciski oraz akcje powodujące usunięcie zasobu lub elementu MUSZĄ być ostylowane na czerwono, tak aby wizualnie odróżniały się od zielonych/limonkowych akcji tworzenia, zapisu i nawigacji.

Przyciski usuwania MUST zachować czytelny kontrast w obu motywach.

#### Scenario: Rozpoznawalność akcji usuwania na liście i w formularzu/potwierdzeniu
- **WHEN** przy elemencie lub w panelu akcji dostępny jest przycisk usuwania
- **THEN** przycisk posiada czerwoną stylistykę z czytelnym tekstem w trybie jasnym oraz ciemnym (`dark:`)

### Requirement: Spójność przycisków zmiany stanów ulików weselnych z osią czasu
Przyciski zmiany stanów ulików weselnych — **(B)** Bezmatek, **(M)** Matecznik, **(N)** Matka nieunasienniona oraz **(UNC)** Matka unasienniona — MUSZĄ odzwierciedlać kolory przypisane tym stanom na osi czasu.

Przyciski stanów MUST zachować zgodność kolorów z osią czasu.

#### Scenario: Dopasowanie koloru przycisku stanu do osi czasu
- **WHEN** użytkownik wyświetla przyciski zmiany stanu ulika weselnego obok lub w powiązaniu z osią czasu
- **THEN** kolorystyka każdego przycisku stanu (`(B)`, `(M)`, `(N)`, `(UNC)`) odpowiada kolorowi danego stanu na osi czasu z zachowaniem czytelnego kontrastu tekstu w trybie jasnym i ciemnym

#### Scenario: Wizualne wyróżnienie aktualnie wybranego/aktywnego stanu
- **WHEN** ulik weselny ma przypisany konkretny stan (`(B)`, `(M)`, `(N)` lub `(UNC)`) lub użytkownik wybiera dany stan
- **THEN** odpowiadający mu przycisk jest wizualnie wyróżniony (np. grubszym obramowaniem, pierścieniem `ring` lub stanem aktywnym `aria-pressed`), podczas gdy inne stany pozostają czytelne i gotowe do wyboru
