# Lista pasieczysk

Widok główny aplikacji prezentujący wszystkie pasieczyska dostępne dla zalogowanego użytkownika.

## Właściwości pasieczyska

Każde pasieczysko posiada:
- Nazwę
- Typ pasieczyska:
  - **Pasieczysko towarowe**
  - **Trutowisko**
- Listę uprawnionych użytkowników (właściciel i członkowie z dostępem).

## Zarządzanie i interakcje

- **Kolejność**: Pasieczyska wyposażone są w strzałki "góra" i "dół", które pozwalają zmieniać ich kolejność wyświetlania na liście. Kolejność jest trwale zapisywana w bazie danych Firestore.
- **Filtrowanie**: Listę pasieczysk można filtrować według ich typu.
- **Nawigacja**: Kliknięcie w wybrane pasieczysko otwiera jego dedykowany widok szczegółowy (dla pasieczyska towarowego lub trutowiska).
