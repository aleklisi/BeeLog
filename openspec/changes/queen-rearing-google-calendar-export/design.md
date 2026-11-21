# Design

## Context

Seria przechowuje harmonogram z datami transferu do finishera, izolacji i przewidywanego wygryzienia. Widok kalendarza prac jest pochodny od tych danych i nie tworzy własnych zdarzeń. Integracja zewnętrzna musi być opcjonalna i działać dla kolejnych serii użytkownika.

## Goals / Non-Goals

**Goals:**
- Umożliwić autoryzację konta Google i eksport wybranej serii.
- Zachować stabilne powiązanie wpisów z serią, aby ponowny eksport nie tworzył duplikatów.
- Tworzyć wpis kalendarza i oddzielne zadanie Google Tasks dla każdego eksportowanego etapu.

**Non-Goals:**
- Dwukierunkowa synchronizacja zmian wprowadzanych bezpośrednio w Google.
- Eksport istniejących lub przyszłych serii automatycznie bez świadomej akcji użytkownika.
- Eksport zdarzeń pasiecznych spoza hodowli matek.

## Decisions

- Eksport jest inicjowany z konkretnej serii. Użytkownik może najpierw połączyć Google, a potem eksportować każdą serię niezależnie.
- Harmonogram daje trzy terminy: transfer do finishera, transfer do cieplarki w dniu izolacji oraz wyjęcie mateczników w dniu przewidywanego wygryzienia. Dla serii kończonej w finisherze pomija się transfer do cieplarki.
- Dla każdego terminu tworzy się Google Calendar event i osobne Google Tasks task. Wpisy zawierają numer serii, nazwę czynności i datę; zadanie jest terminowe w tym samym dniu co wydarzenie.
- Identyfikatory Google i stan eksportu są przechowywane per seria i użytkownik. Ponowny eksport używa istniejących identyfikatorów do aktualizacji; awaria częściowa zachowuje informacje o ukończonych wpisach, aby można było bezpiecznie ponowić próbę.
- Tokeny OAuth przechowuje się zgodnie z istniejącymi granicami bezpieczeństwa aplikacji. Zakresy dostępu ogranicza się do tworzenia i aktualizacji wpisów kalendarza oraz zadań, a odłączenie konta usuwa lokalne poświadczenia i powiązania eksportu.

## Risks / Trade-offs

- Google Calendar i Google Tasks mają osobne API oraz uprawnienia → autoryzacja i eksport muszą obsłużyć niezależne błędy oraz częściowe powodzenie.
- Wygasły lub odwołany token może uniemożliwić aktualizację → pokaż stan połączenia i umożliw ponowną autoryzację.
- Zmiana harmonogramu po eksporcie może pozostawić nieaktualne terminy → ponowny eksport aktualizuje powiązane wpisy; brak automatycznej synchronizacji jest jasno komunikowany.

## Migration Plan

Nowa integracja jest opcjonalna. Istniejące serie i kalendarz w aplikacji działają bez połączenia Google. Przy pierwszym eksporcie identyfikatory wpisów są dopisywane do danych serii; rollback wyłącza akcje eksportu, a nie zmienia lokalnych harmonogramów.
