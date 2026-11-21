# Change: Ujednolicenie kolorów przycisków w panelu Ustawień

## Why

Przyciski w panelu Ustawień przypisują różnym akcjom niespójne kolory, przez co trudniej je rozpoznać i zachować czytelność w obu motywach. Ustalenie spójnych ról dla ciemnej zieleni, jasnej zieleni i czerwieni uporządkuje nawigację, zwijanie sekcji, przełączanie motywu, usuwanie oraz anulowanie.

## What Changes

- Przypisać ciemną zieleń do nawigacji, dodawania oraz przycisku przełączania motywu.
- Przypisać jasną zieleń do przycisków zwijania i rozwijania sekcji.
- Przypisać czerwień do usuwania elementów i konta oraz anulowania potwierdzenia usunięcia.
- Zachować czytelny kontrast tekstu oraz widoczne stany `hover` i `focus` w motywie jasnym i ciemnym.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `ui-theme-colors`: określić role kolorystyczne przycisków nawigacji, dodawania, sekcji, przełączania motywu oraz akcji destrukcyjnych w panelu Ustawień.

## Impact

- Widok ustawień w Elm oraz style przycisków Tailwind/CSS.
- Specyfikacja `ui-theme-colors`.
- Walidacja specyfikacji przez `make test_openspec`.
