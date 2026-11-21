# Proposal

## Why

Podobne komponenty BeeLog różnią się wyglądem, rozmiarem i położeniem akcji, co utrudnia szybkie odnajdywanie najważniejszych czynności i sprawia, że widoki nie tworzą spójnej całości. Wspólne reguły dla przycisków i podstawowych elementów interfejsu uporządkują hierarchię akcji, ich rozmieszczenie oraz zachowanie na małych ekranach.

## What Changes

- Wprowadzić wspólny standard wizualny dla przycisków, pól formularzy, sekcji, kart, komunikatów i grup akcji.
- Ustalić warianty przycisków według roli (główna, drugorzędna, neutralna, destrukcyjna) oraz spójne rozmiary, odstępy i stany interakcji.
- Ustalić przewidywalne rozmieszczenie akcji: główna akcja formularza oddzielona wizualnie od anulowania, akcje elementu grupowane przy tym elemencie, a akcje destrukcyjne odsunięte od zwykłych czynności.
- Zachować czytelność i dostępność w jasnym i ciemnym motywie, na klawiaturze, dotykiem i w układzie mobilnym.
- Objąć standardem główne widoki aplikacji i pogodzić go z istniejącymi zmianami dotyczącymi kolorów przycisków.

## Capabilities

### New Capabilities

- `ui-component-standards`: wspólne warianty, wymiary, rozmieszczenie oraz dostępne stany komponentów i akcji interfejsu.

### Modified Capabilities

- `ui-theme-colors`: doprecyzować semantyczne role kolorów przycisków w ramach wspólnego standardu, zachowując kontrast w obu motywach.

## Impact

- Współdzielone komponenty i klasy stylów Elm/Tailwind oraz widoki formularzy, list, szczegółów, ustawień i okien dialogowych.
- Specyfikacje `ui-component-standards` i `ui-theme-colors`.
- Walidacja zmian OpenSpec przez `make test_openspec`.
- Istniejące propozycje `settings-buttons-color-guidelines` i `commercial-apiary-hive-button-colors` wymagają uzgodnienia z docelowym standardem podczas wdrożenia.
