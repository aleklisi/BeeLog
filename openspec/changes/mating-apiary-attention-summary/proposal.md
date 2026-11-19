# Proposal

## Why

Opiekun powinien móc od razu zauważyć na liście pasiek, że w którymś trutowisku jest ulik wymagający pilnej kontroli. Obecny alert przy pojedynczym uliku jest widoczny dopiero po wejściu do trutowiska, więc lista pasiek nie daje szybkiego przeglądu sytuacji.

## What Changes

- Dodaj czerwony wykrzyknik przy karcie trutowiska na liście pasiek, gdy co najmniej jeden jego ulik ma aktywny alert wymagający natychmiastowej akcji.
- Po najechaniu kursorem lub przeniesieniu fokusu na wykrzyknik pokaż listę nazw wszystkich alertowych ulików.
- Udostępnij tę samą informację w etykiecie dostępności i nie pokazuj wykrzyknika dla trutowisk bez aktywnych alertów.
- Wykorzystaj te same reguły określania wymaganej akcji, które obowiązują przy wykrzykniku na liście ulików.

## Capabilities

### New Capabilities

Brak.

### Modified Capabilities

- `mating-apiaries`: lista trutowisk sygnalizuje obecność ulików wymagających natychmiastowej akcji i podaje ich nazwy.

## Impact

- Widok listy pasiek w `frontend/src/Views/ApiaryList.elm` oraz współdzielenie logiki alertów z `frontend/src/Views/Trutowisko.elm`.
- Testy Elm i e2e dla widoczności alertu, listy nazw, fokusu oraz braku alertu bez wymagających akcji ulików.
- Brak zmian w modelu danych, Firestore i istniejących regułach stanów ulików.
