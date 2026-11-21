# Projekt: Kalendarz zajętości starterów i finisherów

## Model zajętości
Kalendarz jest wyliczany dla każdego startera i finishera z zapisanych serii, które wykorzystują dany zasób. Nie wymaga ręcznego dodawania ani usuwania blokad. Okresy wynikają z etapów harmonogramu, w których zasób jest przypisany do serii; seria planowana również rezerwuje zasób na przewidziany okres.

Daty początku i końca zajętości należy wyznaczać z zapisanych dat serii oraz zapamiętanych ustawień jej harmonogramu, a nie z aktualnych domyślnych ustawień użytkownika. Zmiana harmonogramu lub przypisania serii powinna przeliczyć odpowiedni kalendarz.

## Reguła nakładania się
Przedział nowej serii koliduje z istniejącym okresem zajętości tego samego zasobu, jeśli okresy nakładają się na siebie. Wyjątek: nowy okres może rozpocząć się w dniu zakończenia poprzedniej serii, nawet jeśli ten dzień jest ujęty jako zajęty w poprzednim okresie. Ta reguła ma zastosowanie niezależnie dla starterów i finisherów. Pozostałe nakładające się terminy są niedozwolone.

## Walidacja i widok
Sprawdzenie dostępności powinno następować podczas proponowania oraz zapisywania serii, aby nie dało się utrwalić konfliktu przez edycję ani równoczesne operacje. Interfejs powinien pokazywać zajęte terminy przy zasobie i odróżniać go od zasobów dostępnych w proponowanym okresie. Po zmianie albo usunięciu serii widok dostępności odzwierciedla aktualny stan.

Z listy zasobów starter i finisher otwierają ekran szczegółów z nazwą, numerem ula oraz przedziałami dat i numerami przypisanych serii. Nazwa jest edytowalna i zapisywana na dokumencie zasobu; starsze dokumenty bez nazwy pozostają poprawne.

## Spójność danych
Zmiana serii i wynikająca z niej rezerwacja lub zwolnienie zasobu muszą być atomowe. Kalendarz jest pochodną zapisanych serii, więc nie może pozostać nieaktualny po przerwanym zapisie.
