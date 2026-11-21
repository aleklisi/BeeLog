# Spec Delta

## ADDED Requirements

### Requirement: Ciemnozielone akcje nawigacji, dodawania i przełączania motywu w ustawieniach
Przycisk powrotu z Ustawień, przyciski dodawania elementów list oraz przycisk przełączania motywu MUST używać ciemnozielonej stylistyki z tekstem o czytelnym kontraście w motywie jasnym i ciemnym.

#### Scenario: Rozpoznanie podstawowych akcji
- **WHEN** użytkownik ogląda przycisk powrotu, dodawania lub przełączania motywu w Ustawieniach w dowolnym motywie
- **THEN** przyciski są ciemnozielone, mają czytelny tekst i wyraźne stany `hover` oraz `focus`

### Requirement: Jasnozielone akcje zwijania sekcji
Przyciski zwijania i rozwijania sekcji Ustawień MUST używać jasnozielonej stylistyki z czytelnym tekstem w obu motywach oraz zachowywać bieżące zachowanie `aria-expanded`.

#### Scenario: Rozpoznanie akcji pomocniczych
- **WHEN** użytkownik ogląda lub aktywuje przycisk zwijania albo rozwijania sekcji
- **THEN** przycisk ma jasnozieloną powierzchnię, czytelny tekst, wyraźne stany `hover` i `focus` oraz właściwą wartość `aria-expanded`

### Requirement: Czerwone akcje usuwania i anulowania w ustawieniach
Akcje usuwania elementów z list, rozpoczęcia usuwania konta oraz anulowania potwierdzenia usunięcia MUST używać czerwonej stylistyki z czytelnym kontrastem w obu motywach. Kompaktowe akcje ikonowe MUST pozostać rozpoznawalne i dostępne dla czytników ekranu.

#### Scenario: Rozpoznanie usuwania i anulowania
- **WHEN** użytkownik ogląda akcję usunięcia elementu listy, rozpoczęcia usuwania konta albo anulowania potwierdzenia
- **THEN** akcja jest czerwona, a jej tekst, etykieta dostępności oraz stany `hover` i `focus` pozostają czytelne w motywie jasnym i ciemnym

### Requirement: Wysoki kontrast i widoczne stany interakcji przycisków ustawień
Tekst oraz obramowanie przycisków Ustawień MUST pozostać czytelne względem tła w motywie jasnym i ciemnym, a stan fokusu klawiatury MUST być widoczny.

#### Scenario: Obsługa przycisków klawiaturą w obu motywach
- **GIVEN** użytkownik korzysta z motywu jasnego albo ciemnego
- **WHEN** przenosi fokus klawiaturą na przycisk w Ustawieniach
- **THEN** widoczny wskaźnik fokusu odróżnia przycisk od otoczenia, a tekst pozostaje czytelny
