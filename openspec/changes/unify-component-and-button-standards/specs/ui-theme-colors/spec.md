# Spec Delta

## MODIFIED Requirements

### Requirement: Zielona paleta interfejsu z wysokim kontrastem tekstu (Light i Dark)
Elementy interfejsu oparte na Tailwind CSS MUSZĄ używać spójnej kolorystyki w odcieniach zieleni (np. `green`, `lime`) w trybie jasnym oraz ciemnym (`dark:`), przy zachowaniu czytelnego kontrastu między tłem a tekstem. Główne akcje tworzenia, zapisu i zatwierdzania SHALL używać wspólnej zielonej roli głównej, a akcje drugorzędne, nawigacyjne i anulujące — wspólnej roli drugorzędnej lub neutralnej. Rola i stan akcji MUST być czytelne także przez etykietę, położenie, obramowanie lub dostępną informację o stanie; kolor nie może być jedynym sposobem rozróżnienia akcji.

Implementacja MUST spełnić to wymaganie w obu motywach.

#### Scenario: Kontrast przycisków głównych i drugorzędnych w obu motywach
- **WHEN** użytkownik ogląda przyciski główne lub drugorzędne w trybie jasnym lub ciemnym (`dark:`)
- **THEN** tekst na przycisku ma wysoki kontrast względem tła (np. jasny tekst na głębokiej zieleni lub ciemny tekst na jasnym odcieniu `lime`), a stan `hover` oraz `focus` jest wyraźnie widoczny

#### Scenario: Powierzchnie i pola formularzy w spójnej palecie
- **WHEN** użytkownik korzysta z kart, paneli lub pól formularzy w trybie jasnym lub ciemnym
- **THEN** powierzchnie zachowują spójny kontrast z tekstem i etykietami, a aktywne pole formularza (`focus`) wyróżnia się spójnym zielonym/limonkowym obramowaniem lub pierścieniem

### Requirement: Czerwone przyciski akcji usuwania
Przyciski oraz akcje powodujące usunięcie zasobu lub elementu MUST używać wspólnego czerwonego stylu destrukcyjnego, odróżnialnego od pozostałych ról akcji. Przyciski usuwania MUST zachować czytelny kontrast w obu motywach, a ich rola nie może być rozpoznawalna wyłącznie po kolorze.

#### Scenario: Rozpoznawalność akcji usuwania na liście i w formularzu/potwierdzeniu
- **WHEN** przy elemencie lub w panelu akcji dostępny jest przycisk usuwania
- **THEN** przycisk posiada czerwoną stylistykę z czytelnym tekstem w trybie jasnym oraz ciemnym (`dark:`), a jego etykieta lub położenie odróżnia go od innych akcji
