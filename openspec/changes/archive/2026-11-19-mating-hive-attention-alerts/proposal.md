# Proposal

## Why

Opiekunowie uli weselnych muszą szybko zauważyć ulik wymagający interwencji bez otwierania każdego rekordu. Lista powinna wskazywać czerwonym alertem brak matki oraz przekroczone terminy wygryzienia i unasiennienia, podając przyczynę bezpośrednio przy ikonie.

## What Changes

- Dodaj alert wymagający uwagi po prawej stronie wpisu ulika weselnego na liście.
- Pokazuj alert dla stanu Bezmatek oraz dla przekroczonego oczekiwanego terminu wygryzienia lub unasiennienia zależnego od aktualnego stanu.
- Po najechaniu na alert wyświetl czytelną przyczynę; udostępnij tę informację również przy obsłudze klawiaturą.

## Capabilities

### New Capabilities

Brak.

### Modified Capabilities

- `mating-apiaries`: lista uli weselnych wskazuje ule wymagające uwagi i wyjaśnia przyczynę alertu.

## Impact

- Widok listy uli weselnych w `frontend/src/Views/Trutowisko.elm` oraz jego dane stanu w Elm.
- Istniejące stany ulika, terminy wygryzienia i unasiennienia oraz konfiguracja liczby dni do unasiennienia.
- Specyfikacja `mating-apiaries`.
