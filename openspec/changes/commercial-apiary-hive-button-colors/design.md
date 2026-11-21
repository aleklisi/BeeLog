# Design

## Context

Zob. `proposal.md` — Why. Wspólne style przycisków są w `frontend/src/styles.css`, ale `ApiaryList.elm`, `PasieczyskoTowarowe.elm` i `HiveDetail.elm` nadal ustawiają część kolorów inline. Widoki uli i pasieczysk używają natywnego przeciągania HTML, bez dedykowanego przycisku uchwytu.

## Goals / Non-Goals

**Goals:**
- Zapewnić semantyczne, powtarzalne style, które działają w obu motywach i nie są nadpisywane przez inline `background`.
- Zachować istniejące zdarzenia, etykiety, logikę usuwania oraz zachowanie przeciągania.

**Non-Goals:**
- Zmiana modelu danych, funkcji akcji, nawigacji ani mechanizmu drag-and-drop.
- Zmiana kolorów statusów ulików weselnych lub innych niepowiązanych widoków.

## Decisions

- Rozszerzyć współdzielony system w `styles.css` o semantyczne warianty zielony, czerwony, niebieski i brązowy, z osobno dobranymi wartościami dla `.dark`. Klasy semantyczne będą źródłem kolorów dla przycisków; usunąć z dotkniętych przycisków tylko inline kolory, które je nadpisują. To jest spójniejsze niż rozproszone wartości inline, a istniejące klasy `save-action`, `secondary-action` i `destructive-action` pozostaną kompatybilne.
- Użyć zielonego wariantu dla tworzenia, zmiany nazwy, zapisu i nawigacji; czerwonego dla anulowania i usuwania; niebieskiego dla akcji NFC; brązowego dla dyktowania. Dla małych ikonowych przycisków zastosować warianty z czytelną powierzchnią lub czerwonym/niebieskim/brązowym kolorem ikony, aby nie pogorszyć ich rozmiaru ani układu.
- Dla natywnych kart przeciąganych dodać widoczny stan przeciągania na karcie oraz neutralne wskazanie możliwości chwytu. Rozszerzyć to wyłącznie na pasieczyska i komercyjne ule wymienione w specyfikacji; nie zmieniać sposobu wyzwalania drag-and-drop.
- Zachować wspólny widoczny `focus-visible` i hover; nie polegać na `dark:` z Tailwind tam, gdzie istniejące reguły CSS są już źródłem stylów motywu.

## Risks / Trade-offs

- [Globalne reguły przycisków i inline style mogą przysłonić nowe warianty] → Używać istniejących semantycznych klas CSS i wyczyścić kolidujące kolory tylko w zmienianych kontrolkach.
- [Przyciski ikonowe mogą stać się zbyt ciężkie wizualnie] → Zachować kompaktowe wymiary i użyć stonowanych powierzchni z kontrastującą ikoną tam, gdzie pełne tło byłoby nieczytelne.
- [Zmiana hover/focus może pogorszyć widoczność w jednym motywie] → Uwzględnić oba motywy w testach widoków i zachować pierścień fokusu klawiatury.
