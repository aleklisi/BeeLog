# Proposal

## Why

Harmonogram serii hodowlanej jest dostępny w aplikacji, ale użytkownik musi ręcznie przenosić terminy do kalendarza, aby pamiętać o pracy przy rodzinach. Integracja z Google pozwoli zaplanować trzy kluczowe przeniesienia lub czynności wraz z zadaniami przypominającymi o ich wykonaniu.

## What Changes

- Dodać możliwość połączenia konta Google i eksportu każdej serii osobno do Google Calendar.
- Dla serii tworzyć wydarzenia i odpowiadające im zadania: przeniesienie ze startera do finishera, przeniesienie z finishera do cieplarki oraz wyjęcie mateczników z cieplarki w dniu przewidywanego wygryzienia.
- Zapewnić ponowny eksport bez tworzenia duplikatów oraz czytelną informację o powodzeniu lub błędzie.

## Capabilities

### New Capabilities

### Modified Capabilities
- `queen-rearing`: dodanie eksportu harmonogramu serii do Google Calendar oraz zadań Google Tasks.

## Impact

- Zmiana widoku i danych serii hodowlanych w aplikacji Elm.
- Autoryzacja Google i zapis powiązań eksportowanych wydarzeń oraz zadań z serią.
- Integracja z Google Calendar API i Google Tasks API; wymagane zgody OAuth oraz konfiguracja klienta Google.
