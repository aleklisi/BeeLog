# Zajętość starterów i finisherów w kalendarzu

## Dlaczego
Przy planowaniu serii hodowlanych użytkownik nie widzi, kiedy konkretny starter lub finisher jest już przypisany do innej serii. Może to prowadzić do zaplanowania równoczesnego użycia tego samego zasobu. Kalendarz zajętości pozwoli uwzględnić terminy serii przy wyborze zasobu.

## Zakres zmian
- Każdy starter i finisher ma kalendarz zajętości wynikający z przedziałów użycia w seriach hodowlanych.
- Przy proponowaniu lub zapisywaniu serii aplikacja sprawdza, czy wybrany zasób jest wolny w wymaganym okresie, i nie pozwala na konfliktujące przypisanie.
- Ponowne użycie zasobu jest dozwolone, gdy nowy proponowany okres zaczyna się dokładnie w dniu zakończenia poprzedniej serii korzystającej z tego zasobu.
- Kalendarz i informacja o dostępności są aktualizowane przy zmianie terminów, przypisania zasobu, postępu lub usunięciu serii.
- Kliknięcie startera lub finishera otwiera szczegóły z terminami przypisanych serii; użytkownik może nadać zasobowi własną nazwę.

## Wpływ
- Zmieniana specyfikacja: `queen-rearing`.
- Implementacja obejmie obliczanie okresów zajętości startera i finishera na podstawie harmonogramu serii oraz walidację dostępności przy planowaniu i aktualizacji serii.
