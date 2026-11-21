# Proposal

## Why

Lista pokazuje termin i kolor pilności następnego działania, ale użytkownik musi odczytać szczegóły każdej karty, by zauważyć serię wymagającą pracy dzisiaj. Czerwony wykrzyknik przy numerze serii pozwoli szybko wychwycić aktywne serie z działaniem zaplanowanym na dziś lub zaległym.

## What Changes

- Dodać czerwony wykrzyknik obok identyfikatora aktywnej serii, gdy termin jej następnego działania przypada dziś lub minął.
- Oprzeć alert na istniejącym następnym działaniu wynikającym ze statusu serii i jej zapisanego harmonogramu.
- Udostępnić powód alertu przez podpowiedź i etykietę dostępną dla czytników ekranu.
- Nie oznaczać serii zaplanowanych, które nie mają rozpoczętego harmonogramu, ani serii ukończonych.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `queen-rearing`: dodanie widocznego i dostępnego alertu dla aktywnych serii wymagających działania dziś lub po terminie.

## Impact

Zmiana dotyczy listy serii w widoku Hodowli matek oraz istniejących reguł wyznaczania terminu następnego działania. Nie wymaga zmian danych ani synchronizacji Firestore.
