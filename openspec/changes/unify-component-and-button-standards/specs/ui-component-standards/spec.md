# Spec Delta

## Purpose

Definiuje wspólne, rozpoznawalne zasady wyglądu i rozmieszczenia komponentów BeeLog, aby użytkownicy mogli przewidywać sposób obsługi formularzy, list, kart, sekcji i akcji w różnych widokach.

## ADDED Requirements

### Requirement: Spójne role i hierarchia przycisków
Przyciski o tej samej roli w różnych widokach MUST mieć rozpoznawalny, wspólny wygląd i hierarchię wizualną. Tekst przycisku MUST jasno opisywać wykonywaną czynność.

#### Scenario: Porównanie głównych akcji w różnych widokach
- **WHEN** użytkownik widzi główną akcję w formularzu lub widoku
- **THEN** akcja ma tę samą wyraźną hierarchię wizualną co główne akcje w pozostałych widokach

#### Scenario: Akcje o różnych rolach
- **WHEN** obok siebie są dostępne akcja główna, drugorzędna i destrukcyjna
- **THEN** każda rola jest wizualnie odróżnialna, a akcja główna jest łatwa do odnalezienia

### Requirement: Przewidywalne rozmieszczenie akcji
Akcje MUST być umieszczane blisko elementu lub treści, których dotyczą, i grupowane według kontekstu. Główna akcja formularza MUST być łatwa do odnalezienia, a anulowanie i usuwanie MUST nie być mylone z jej uruchomieniem.

#### Scenario: Akcje w formularzu
- **WHEN** użytkownik wypełnia formularz z akcją zatwierdzenia i anulowania
- **THEN** akcje są pogrupowane przy końcu formularza, zatwierdzenie jest wizualnie główne, a anulowanie pozostaje odrębne

#### Scenario: Akcje elementu listy
- **WHEN** lista wyświetla elementy z własnymi akcjami
- **THEN** akcje każdego elementu pozostają wizualnie związane z tym elementem i nie są mylone z akcjami innych elementów

#### Scenario: Akcja destrukcyjna wśród innych akcji
- **WHEN** usuwanie jest dostępne obok zwykłych działań
- **THEN** akcja usuwania jest odróżniona i odsunięta od przypadkowego uruchomienia

### Requirement: Spójne wymiary i odstępy komponentów
Powtarzające się przyciski, pola formularzy, nagłówki sekcji, karty i grupy akcji MUST zachowywać spójne rozmiary, wyrównanie i odstępy w porównywalnych kontekstach.

#### Scenario: Porównanie pól formularzy
- **WHEN** użytkownik porównuje pola o podobnej funkcji w różnych widokach
- **THEN** pola mają spójne wymiary, wyrównanie etykiet i odstępy

#### Scenario: Porównanie kart i sekcji
- **WHEN** użytkownik przegląda karty lub sekcje w różnych widokach
- **THEN** ich nagłówki, zawartość i odstępy stosują spójny układ

### Requirement: Responsywne rozmieszczenie komponentów
Komponenty i grupy akcji MUST zachowywać czytelność i możliwość obsługi na wąskich ekranach bez obcinania etykiet ani nakładania się elementów.

#### Scenario: Grupa wielu akcji na wąskim ekranie
- **WHEN** grupa przycisków jest wyświetlana na wąskim ekranie
- **THEN** przyciski układają się w czytelny sposób, pozostają dostępne i nie nachodzą na treść

#### Scenario: Długa etykieta przycisku
- **WHEN** etykieta akcji jest dłuższa w jednym z obsługiwanych języków
- **THEN** układ zachowuje czytelność etykiety i nie ukrywa głównej akcji

### Requirement: Dostępne stany interakcji komponentów
Interaktywne komponenty MUST zapewniać widoczne stany fokusu i aktywności oraz wystarczającą informację o stanie, aby obsługa klawiaturą i dotykiem była zrozumiała.

#### Scenario: Obsługa przycisku klawiaturą
- **WHEN** użytkownik przenosi fokus klawiaturą na przycisk
- **THEN** fokus jest wyraźnie widoczny, a aktywacja przycisku działa zgodnie z jego etykietą

#### Scenario: Przełącznik lub wybór aktywnej opcji
- **WHEN** użytkownik wybiera lub przełącza interaktywny komponent
- **THEN** jego stan wybrany lub włączony jest wizualnie rozpoznawalny i dostępny dla technologii asystujących

#### Scenario: Obsługa dotykowa
- **WHEN** użytkownik obsługuje akcje na urządzeniu dotykowym
- **THEN** elementy interaktywne mają czytelne etykiety i są rozmieszczone tak, aby można je było osobno aktywować
