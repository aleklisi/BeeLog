# Proposal

## Why

Akcje w widokach pasieczysk i uli towarowych mają mieszane, częściowo zapisane inline kolory, przez co podobne działania wyglądają inaczej, a ich czytelność zależy od motywu. Semantyczne kolory ułatwią rozpoznawanie nawigacji, zapisu, usuwania, obsługi NFC i dyktowania.

## What Changes

- Nadać akcjom tworzenia, zmiany nazwy, zapisu i nawigacji ciemnozielony wygląd z czytelnym tekstem oraz stanami hover i focus w obu motywach.
- Nadać akcjom usuwania i anulowania czerwony wygląd, a obsłudze NFC niebieski wygląd.
- Nadać dyktowaniu notatek ciepły brązowy wygląd; zachować ich czytelność także podczas nagrywania.
- Zapewnić neutralny, widoczny uchwyt i wyróżnienie przeciąganego kafelka pasieczyska lub ula.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `apiary-views`: określić wizualne role akcji tworzenia, zmiany nazwy, usuwania i nawigacji pasieczysk.
- `commercial-hive-ordering`: określić czytelność kafelków oraz stan przeciągania podczas zmiany kolejności uli.
- `hives`: określić role kolorystyczne akcji zarządzania, zapisu, anulowania i dyktowania w szczegółach ula.
- `nfc-and-data`: określić niebieski wygląd akcji kopiowania lub przypisywania linku/tagu NFC.

## Impact

- Widoki Elm: `ApiaryList`, `PasieczyskoTowarowe` i `HiveDetail` oraz współdzielone style przycisków.
- Testy interfejsu widoków i walidacja OpenSpec przez `make test_openspec`.
