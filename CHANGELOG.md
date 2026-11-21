# Changelog

## [2026-11-21] Naprawa ustawień i testów E2E hodowli matek

- Przywrócono odczyt ustawienia włączającego hodowlę matek i zaktualizowano scenariusze E2E do tworzenia zaplanowanych serii.

## [2026-11-21] Naprawa testów Elm hodowli matek

- Dostosowano testy walidacji harmonogramu i sortowania serii do aktualnych reguł domenowych.

## [2026-11-21] Numer serii z rokiem i licznikiem rocznym

- Numery serii mają format `RRRR/N`, a kolejny numer jest przydzielany osobno dla każdego roku.

## [2026-11-21] Serie hodowlane od najwyższego numeru

- Lista serii jest sortowana malejąco według numeru, niezależnie od statusu i terminu kolejnego działania.

## [2026-11-21] Dane serii wymagane przy rozpoczęciu

- Planowaną serię można utworzyć bez wyboru matki reproduktorki i liczby larw; oba pola są wymagane przy jej rozpoczęciu.

## [2026-11-21] Doprecyzowanie przeniesienia do finiszera

- Oś czasu pokazuje przeniesienie do finiszera w dniu następującym po czasie pracy startera.

## [2026-11-21] Doprecyzowanie dnia 0 harmonogramu matek

- Opisano dzień 0 jako przekładanie larw i umieszczenie ich w starterze.

## [2026-11-21] Domyślny harmonogram hodowli matek

- Dopasowano domyślny czas w starterze do 1 dnia, izolację do 10. dnia i wygryzienie do 12. dnia zgodnie z kalendarzem Starter–Finisher.

## [2026-11-21] Poprawa asercji testów hodowli matek

- Zaktualizowano oczekiwane komunikaty błędów E2E do polskich tłumaczeń wyświetlanych przez aplikację.

## [2026-11-21] Ujednolicenie pól szczegółów serii hodowlanej

- Pola tekstowe i dropdowny w szczegółach serii mają teraz ten sam rozmiar i kolorystykę co pola w szczegółach ula.

## [2026-11-21] Tłumaczenie komunikatów błędów według języka

- Dodano polskie komunikaty dla błędów walidacji, operacji hodowlanych i typowych błędów Firebase; okno usuwania konta korzysta z tych samych tłumaczeń.

## [2026-11-21] Polskie tłumaczenie błędu odwołania do dokumentu

- Błąd nieprawidłowej ścieżki dokumentu Firestore jest wyświetlany po polsku przy polskim języku aplikacji.

## [2026-11-21] Naprawa tworzenia serii wychowu

- Numer serii jest przydzielany z licznika odczytywanego w transakcji Firestore, bez próby pobierania zapytania kolekcji w transakcji.

## [2026-11-21] Naprawa nieaktualnych scenariuszy E2E

- Uodporniono test zgody na zapisany wybór i zaktualizowano test edycji matki reprodukcyjnej do widoku szczegółowego.

## [2026-11-21] Szczegóły matek reprodukcyjnych

- Dodano widok szczegółowy matki z informacjami o jej oznakowaniu, statusie i powiązanych seriach oraz akcjami edycji i usuwania.

## [2026-11-21] Uproszczenie list zasobów hodowlanych

- Usunięto przyciski edycji z list matek reprodukcyjnych, starterów i finisherów, a usuwanie oznaczono ikoną kosza.

## [2026-11-21] Podział testów E2E według widoków

- Rozdzielono scenariusze E2E na pliki dotyczące list pasiek, pasiek towarowych, trutowisk, hodowli matek oraz logowania i ustawień.

## [2026-11-21] Aktualizacja selektorów E2E hodowli matek

- Dostosowano testy E2E formularzy reproduktorek, starterów i finisherów do identyfikatorów pól zawierających typ zasobu.

## [2026-11-21] Poprawa typu formularza zasobów

- Poprawiono adnotację typu słownika formularza, aby kompilacja Elm przechodziła przed uruchomieniem testów.

## [2026-11-21] Ikony akcji szczegółów zasobów

- Przyciski edycji i usuwania startera oraz finishera zastąpiono ikonami ołówka i kosza.

## [2026-11-21] Ukrycie listy zasobów w szczegółach

- Szczegóły startera i finishera pokazują wyłącznie wybrany zasób, kalendarz serii oraz akcje edycji i usuwania.

## [2026-11-21] Edycja startera i finishera w szczegółach

- Usunięto formularz dodawania ze szczegółów zasobu; pola nazwy i numeru ula pojawiają się tylko podczas edycji i znikają po zapisie lub anulowaniu.

## [2026-11-21] Rozdzielenie pól zasobów hodowlanych

- Pola numeru ula i nazwy w formularzach starterów, finisherów i matek hodowlanych przechowują teraz niezależne wartości.

## [2026-11-21] Polskie tłumaczenie błędu daty przekładania

- Komunikat o nieprawidłowej dacie przekładania larw jest wyświetlany po polsku przy polskim języku aplikacji.

## [2026-11-21] Usunięcie pola strefy czasowej z serii hodowlanej

- Usunięto pole IANA strefy czasowej z formularza startu serii i szczegółów serii.

## [2026-11-21] Poprawa walidacji specyfikacji kalendarza zasobów

- Uzupełniono zmieniony wymóg rezerwacji o zachowane scenariusze z głównej specyfikacji.

## [2026-11-21] Szczegóły starterów i finisherów

- Kliknięcie zasobu otwiera kalendarz serii, które go używają; startery i finishery mają też edytowalne nazwy.

## [2026-11-21] Widok szczegółów serii wychowu

- Lista serii pokazuje numer, stan i daty, a kliknięcie otwiera pełny widok serii z ikoną kosza.

## [2026-11-21] Testy E2E widoku serii wychowu

- Scenariusze E2E uwzględniają przechodzenie między listą a szczegółami serii.

## [2026-11-21] Aktualizacja testu Elm zasobów wychowu

- Test kodowania kolonii uwzględnia teraz pole nazwy startera lub finishera.

## [2026-11-21] Kalendarz zajętości starterów i finisherów

- Dodano OpenSpec dla kalendarza dostępności zasobów z regułą ponownego użycia od dnia zakończenia poprzedniej serii.

## [2026-11-21] Numerowanie serii hodowlanych

- Serie hodowlane otrzymują kolejne numery naturalne, niezależnie od roku.

## [2026-11-21] Oś czasu serii hodowli matek

- Każda seria pokazuje etapy przekładania larw, startera, finishera, opcjonalnego inkubatora i wygryzienia.

## [2026-11-21] Poprawa dat w testach E2E wychowu matek

- Dostosowano wartości pól daty w scenariuszach E2E do formatu `YYYY-MM-DD`.

## [2026-11-21] Testy harmonogramu wychowu matek

- Zaktualizowano testy Elm dla dat przekładania i etapów serii bez godziny.

## [2026-11-21] Szybsze aktualizacje hodowli matek

- Dane hodowli matek są aktualizowane na bieżąco przez nasłuch Firestore; migracja starych danych uruchamia się tylko przy pierwszym wczytaniu.

## [2026-11-21] Data przekładania larw bez godziny

- Seria wychowu matek zapisuje i wyświetla datę przekładania larw bez wyboru godziny i minut.

## [2026-11-21] Styl pola aktywnej matki reprodukcyjnej

- Ujednolicono wygląd wyboru aktywnej matki reprodukcyjnej z wyborem typu uliku weselnego.

## [2026-11-21] Naprawa pomiaru coverage w CI

- Ustawiono Node 20 w jobie `elm-coverage`, aby uniknąć błędu inicjalizacji portów `elm-test` na Node 24.

## [2026-11-21] Uproszczenie listy reproduktorek

- Usunięto akcję „Wycofaj” oraz widoczny status aktywności reproduktorek z widoku zasobów.

## [2026-11-21] Aktualizacja asercji E2E kolorów opalitków

- Dostosowano oczekiwany tekst reproduktorki do ujednoliconych etykiet kolorów.

## [2026-11-21] Ujednolicone kolory opalitków

- Dodano kolorowe emotikony i tłumaczenia kolorów opalitków w ulach, ulikach oraz hodowli matek.

## [2026-11-21] Sekcje zasobów hodowli matek jak w ustawieniach

- Ujednolicono nagłówki i strzałki zwijania sekcji zasobów ze stylem sekcji w Ustawieniach.

## [2026-11-21] Numery uli hodowli matek jako liczby całkowite

- Zmieniono numery uli reproduktorek, starterów i finisherów na wartości całkowite w modelu i zapisie Firestore.

## [2026-11-21] Główne kolekcje hodowli matek

- Przeniesiono matki reprodukcyjne, startery, finishery i serie hodowlane do kolekcji głównych Firestore z kontrolą właściciela przez `userId` oraz migracją istniejących danych.

## [2026-11-21] Odświeżanie danych hodowli matek

- Po udanych zmianach w hodowli matek i zasobach aplikacja ponownie pobiera dane z Firestore.

## [2026-11-21] Styl przycisku przenoszenia ulika

- Dopasowano rozmiar i wygląd przycisku „Przenieś” do przycisku „Zapisz”, zachowując żółte kolory akcji z ikoną 🚚.

## [2026-11-21] Równa wysokość przycisków zmiany stanu

- Ustawiono jednakową wysokość przycisków zmieniających stan ulika.

## [2026-11-21] Równa szerokość przycisków edycji notatki

- Ustawiono taką samą szerokość przycisków „Zapisz” i „Anuluj” podczas edycji notatki.

## [2026-11-21] Ukrywanie przycisku Google po zalogowaniu

- Wyczyść przycisk Google Identity Services po zalogowaniu i dodaj test jego usunięcia z widoku aplikacji.

## [2026-11-21] Renderowanie przycisku Google po wylogowaniu

- Ponownie renderuj oficjalny przycisk logowania po powrocie z widoków aplikacji.

## [2026-11-21] Testy logowania Google

- Zaktualizowano testy e2e dla przycisku Google Identity Services i ustabilizowano jego renderowanie po uruchomieniu Elm.

## [2026-11-21] Oficjalny przycisk logowania Google

- Zastąpiono własny przycisk przyciskiem Google Identity Services i połączono go z logowaniem Firebase.

## [2026-11-21] Ciemnoniebieskie tło przycisku logowania Google

- Ustawiono wyraźnie ciemniejszy, nasycony niebieski kolor tła przycisku logowania Google.

## [2026-11-21] Niebieski przycisk logowania Google

- Dopasowano wymiary i zaokrąglenie przycisku logowania Google do stylu przycisku „Zasoby”, zachowując niebieski kolor.

## [2026-11-21] Żółty przycisk zabierania matki

- Dopasowano wygląd przycisku „zabieram matkę (B)” do przycisku „Zaopalitkuj”.

## [2026-11-21] Zaokrąglone przyciski akcji destrukcyjnych

- Zaokrąglono rogi czerwonych przycisków akcji, w tym „❌ Matecznik się nie wygryzł (B)”.

## [2026-11-21] Żółte przyciski przenoszenia ulików

- Ustawiono żółte tło wszystkich przycisków z ikoną ciężarówki.

## [2026-11-21] Wskaźnik ładowania pasieczysk

- Podczas pobierania pasieczysk wyświetlaj krótkie animowane kółko zamiast komunikatu o pustej liście.

## [2026-11-21] Styl przycisku wygryzienia matki

- Dopasowano kolor i wygląd przycisku „🦋 Matka się wygryzła (N)” do przycisku „Zasoby”.

## [2026-11-21] Żółte przyciski edycji

- Ujednolicono tło, kolor i obramowanie przycisków z ikoną ✏️ ze stylem „🏷️ Zaopalitkuj”.

## [2026-11-21] Styl przycisków anulowania

- Ujednolicono kolor i wygląd przycisków „Anuluj” ze stylem przycisku „Usuń konto”.

## [2026-11-21] Czerwone przyciski usuwania

- Ustawiono czerwone tło wszystkich przycisków z ikoną kosza.

## [2026-11-21] Uproszczenie edytora korpusów

- Przeniesiono opis edytora korpusów do dymku informacyjnego obok tytułu.

## [2026-11-21] Wysokość przycisków akcji destrukcyjnych

- Ustawiono minimalną wysokość przycisku „Matecznik się nie wygryzł (B)” na 36 px, zgodnie z przyciskiem opróżniania ulika.

## [2026-11-21] Wysokość przycisku usuwania konta

- Ustawiono minimalną wysokość przycisku „Usuń konto” na 36 px, zgodnie z przyciskiem opróżniania ulika.

## [2026-11-21] Styl przycisku nieudanego matecznika

- Dopasowano przycisk „❌ Matecznik się nie wygryzł (B)” do stylu „🧹 Opróżnij ulik (P)”.

## [2026-11-21] Styl przycisku dyktowania

- Dopasowano kolor i wygląd przycisku „🎤 Dyktuj” do przycisku „Zaopalitkuj”.

## [2026-11-21] Styl przycisku zrzutu ula

- Dopasowano kolor i wygląd przycisku „📸 Zrzut Ula” do przycisku „Zaopalitkuj”.

## [2026-11-21] Styl przycisku zapisywania notatki

- Ujednolicono wygląd przycisku „Zapisz Notatkę” ze stylem przycisków zapisu w widoku Zasobów.

## [2026-11-21] Pionowy układ przycisków stanu ulika

- Ułożono przyciski zarządzania stanem ulika weselnego jeden pod drugim.

## [2026-11-21] Aktualizacja testu edytora korpusów

- Dostosowano oczekiwaną kolejność po upuszczeniu korpusu pod korpusem z matką.

## [2026-11-21] Przyciski stanów ulika w dwóch kolumnach

- Ułożono akcje zarządzania stanem ulika weselnego obok siebie w siatce dwóch kolumn.

## [2026-11-21] Styl przycisku opróżniania ulika

- Dopasowano wygląd i kolor przycisku „Opróżnij ulik (P)” do przycisku „Usuń konto”.

## [2026-11-21] Styl przycisku utraty matki

- Dopasowano wygląd i kolor przycisku „Matka strutowiała / zniknęła (B)” do przycisku „Usuń konto”.

## [2026-11-21] Styl przycisku unasiennienia matki

- Ujednolicono wygląd i kolor przycisku „Matka się unasienniła (UNC)” z przyciskiem „Zasoby”.

## [2026-11-21] Przeciąganie korpusów ula

- Ujednolicono przeciąganie i upuszczanie korpusów z mechanizmem używanym na listach pasieczysk i uli.

## [2026-11-21] Styl przycisku zaopalitkowania

- Dopasowano wygląd przycisku „Zaopalitkuj” do przycisku „Poddano matecznik”.

## [2026-11-21] Styl przycisku opróżniania ulika

- Dopasowano wygląd przycisku „Opróżnij ulik” do przycisku „Poddano matecznik”.

## [2026-11-21] Kolor przycisku unasiennienia matki

- Dopasowano tło przycisku „Matka się unasienniła” do przycisku „Zasoby”.

## [2026-11-21] Zaokrąglony przycisk usuwania konta

- Dopasowano zaokrąglenie przycisku „Usuń konto” do przycisku „Zasoby”.

## [2026-11-21] Akcje ulików weselnych obok nazwy

- Przeniesiono przyciski przenoszenia, edycji i usuwania do nagłówka karty ulika, obok jego nazwy.

## [2026-11-21] Akcje pasieczysk obok taga

- Przeniesiono edycję i usuwanie pasiek towarowych oraz trutowisk do wiersza z tagiem typu pasieki, po jego prawej stronie.

## [2026-11-21] Akcje trutowisk w nagłówku karty

- Przeniesiono edycję i usuwanie do prawej strony wiersza z tagiem, zaraz po nazwie.

## [2026-11-21] Akcje pasiek towarowych w nagłówku karty

- Przeniesiono edycję i usuwanie obok taga typu pasieki, a tag ustawiono zaraz po nazwie.

## [2026-11-21] Uproszczenie akcji na kartach uli towarowych

- Usunięto przycisk edycji nazwy i przeniesiono kosz obok nazwy ula, po prawej stronie.

## [2026-11-21] Uzupełnienie specyfikacji kolorów

- Zastąpiono placeholder w sekcji Purpose specyfikacji `ui-theme-colors` opisem jej zakresu.

## [2026-11-21] Semantyczne kolory akcji w Ustawieniach

- Ujednolicono kolory nawigacji, dodawania, przełączania motywu, zwijania sekcji oraz czerwonych akcji usuwania i anulowania.
- Dodano test E2E stylów, fokusu klawiatury i motywów jasnego oraz ciemnego.

## [2026-11-21] Specyfikacja kolorów akcji pasieczysk i uli

- Dodano zmianę OpenSpec opisującą semantyczne kolory akcji w pasieczyskach i ulach towarowych w obu motywach.

## [2026-11-21] Specyfikacja kolorów przycisków Ustawień

- Przeniesiono brief z TODO do zmiany OpenSpec opisującej role kolorów przycisków Ustawień w obu motywach.

## [2026-11-20] Wyraźniejsze przyciski zapisu

- Wzmocniono wygląd przycisków zapisu w formularzach i oknach dialogowych.

## [2026-11-20] Zielona paleta i kolory stanów ulików

- Ujednolicono zielone akcje, czerwone usuwanie oraz kolory i wyróżnienie aktualnego stanu uliku weselnego.

## [2026-11-20] Przyciemnienie przycisków

- Zmieniono wspólny kolor przycisków na ciemny grafit, dopasowany do ikony menu.

## [2026-11-20] Poprawka trybów kolorystycznych Tailwind

- Powiązano wariant `dark:` Tailwinda z klasą `.dark` i synchronizowano ją z zapamiętanym ustawieniem motywu.

## [2026-11-20] Zmiana koloru przycisków

- Ustawiono wspólny kolor przycisków na `oklch(52.7% 0.154 150.069)`, zachowując wcześniej ustalone wyjątki.

## [2026-11-20] Doprecyzowanie przycisku przenoszenia ulika

- Zmieniono nazwę testową kontrolki na `MoveMatingHive` i dodano podpowiedź „Przenieś ulik na inne trutowisko”.

## [2026-11-20] Ulepszony przycisk zmiany motywu

- Dodano opis kierunku zmiany motywu oraz gwiazdki w przycisku trybu ciemnego; przycisk trybu jasnego ma jasne tło i ikonę słońca.

## [2026-11-20] Ujednolicenie kolorów przycisków

- Ustawiono lime dla przycisków akcji, głęboki czerwony dla usuwania konta oraz wspólny styl powrotu z zasobów hodowli matek.

## [2026-11-20] Jasnozielony interfejs i przyciski korpusów

- Ujednolicono przyciski dodawania korpusu nad i pod przy pomocy klas Tailwind oraz rozjaśniono tło aplikacji w trybie jasnym.

## [2026-11-20] Wydzielenie zasobów hodowli matek

- Dodano widok z trzema zwijanymi sekcjami do zarządzania reproduktorkami, starterami i finisherami.
- Przeniesiono formularze i listy zasobów z widoku serii, dodano obsługę ras i linii z ustawień oraz dostosowano testy E2E.

## [2026-11-20] Usunięcie przycisku Ustawienia z hodowli matek

- Usunięto przycisk „Ustawienia” z nagłówka widoku hodowli matek.

## [2026-11-20] Ujednolicenie stylu przycisków

- Dodano wspólny styl Tailwind dla przycisków oraz zielone kolory akcji i czerwone dla anulowania, odrzucania i usuwania.

## [2026-11-20] Dokończenie polityki prywatności

- Domknięto dwujęzyczny dialog polityki, testy tej zmiany i synchronizację specyfikacji przed archiwizacją.

## [2026-11-20] Prywatność i zgody

- Dodano dwujęzyczną politykę prywatności, baner wyboru pamięci oraz ustawienia zgód z zapisem w localStorage.
- Dodano testy tłumaczeń Elm i scenariusze E2E dla polityki oraz wyborów prywatności.

## [2026-11-20] Aktualizacja README na podstawie OpenSpec

- Przepisano README.md z pełnym opisem dostępnej i planowanej funkcjonalności na podstawie wszystkich specyfikacji OpenSpec (`main-navigation`, `apiary-views`, `hives`, `mating-apiaries`, `queen-rearing`, `nfc-and-data`, `settings-and-user`, `account-deletion`, `firestore-access-control`, `privacy-and-consent`).

## [2026-11-20] Stabilizacja testu przeciągania kart

- Dodano pośrednie kroki ruchu myszy w przeciąganiu kart, aby stabilnie wywoływać zdarzenia dragover.

## [2026-11-20] Synchronizacja i archiwizacja usuwania konta

- Zsynchronizowano wymagania samodzielnego usuwania konta z główną specyfikacją i zarchiwizowano zmianę OpenSpec.

## [2026-11-20] Poprawione upuszczanie kafelków na końcu listy

- Zapamiętuj ostatnią kartę pod kursorem podczas przeciągania, aby umożliwić przeniesienie kafelka na ostatnią pozycję.

## [2026-11-20] Poprawa frazy potwierdzającej usunięcie konta

- Poprawiono literówkę „koto” na „konto” w dialogu, walidacji i specyfikacjach usuwania konta.

## [2026-11-20] Samodzielne usuwanie konta bez Functions

- Usunięto Firebase callable function i przełączono usuwanie konta na Firebase client SDK.

## [2026-11-19] Synchronizacja i archiwizacja kontroli dostępu

- Dodano główne specyfikacje kontroli dostępu Firestore i kolejności pasieczysk oraz zarchiwizowano zmianę `firestore-access-control`.

## [2026-11-19] Usunięcie udostępniania pasiek

- Usunięto współdzielenie i odczyty współpracowników; listę pasiek ograniczono do własności zalogowanego użytkownika i pobiera się szybciej równolegle.
- Zmieniono reguły Firestore na dostęp właściciela oraz zaktualizowano OpenSpec, dokumentację i testy.

## [2026-11-19] Synchronizacja i archiwizacja podsumowania alertów trutowiska

- Zsynchronizowano główną specyfikację mating-apiaries o wymagania alertów na karcie trutowiska i zarchiwizowano zmianę mating-apiary-attention-summary w OpenSpec.

## [2026-11-19] Synchronizacja danych po powrocie z list i szczegółów

- Przy powrocie do listy pasieczysk zsynchronizuj aktualne ule i uliki z kartami pasieczysk, aby podsumowania odzwierciedlały ostatnie zmiany.

## [2026-11-19] Odświeżanie podsumowania trutowiska

- Synchronizuj listę ulików w danych trutowiska po odebraniu zmian, aby liczba ulików i zliczenia stanów były aktualne.

## [2026-11-19] Podsumowanie alertów ulików na karcie trutowiska

- Dodano czerwony wykrzyknik przy karcie trutowiska z listą nazw alertowych ulików w tooltipie i etykiecie dostępności.
- Wydzielono wspólną logikę sprawdzania alertów dla ulików i zachowano brak alertu dla pasiek towarowych oraz trutowisk bez wymagających akcji ulików.
- Dodano testy jednostkowe Elm dla filtrowania nazw ulików i formatowania podsumowania oraz test E2E weryfikujący wyświetlanie, fokus i brak nawigacji po kliknięciu wykrzyknika.

## [2026-11-19] Animacja przeciągania korpusów

- Dodano animowane podświetlenie przeciąganego korpusu, płynne reakcje stref upuszczania i efekt uchwytu z klasami Tailwind.

## [2026-11-19] Widoczna instrukcja edytora korpusów

- Przeniesiono opis zarządzania i instrukcję przeciągania korpusów z dymku do widocznej treści edytora.

## [2026-11-19] Synchronizacja i archiwizacja styli ustawień oraz Tailwind CSS

- Zaktualizowano główną specyfikację settings-and-user o wymagania spójnego wyglądu kontrolek liczbowych i przełączników modułów.
- Zarchiwizowano zmianę standardize-settings-controls-and-tailwind w OpenSpec.

## [2026-11-19] Implementacja i archiwizacja alertów uwagi ulików weselnych

- Zaimplementowano weryfikację alertów uwagi na liście ulików weselnych oraz rozszerzono testy E2E o termin 30 dni i wielokrotne powody.
- Zsynchronizowano główną specyfikację mating-apiaries i zarchiwizowano zmianę mating-hive-attention-alerts w OpenSpec.

## [2026-11-19] Propozycja ujednolicenia styli ustawień

- Dodano zmianę OpenSpec dla integracji Tailwind CSS i spójnego wyglądu pól liczbowych oraz przełączników modułów.

## [2026-11-19] Synchronizacja i archiwizacja obsługi języków

- Przeniesiono wymagania wyboru języka do głównej specyfikacji i zarchiwizowano zmianę OpenSpec.

## [2026-11-19] Dostosowany test przeciągania korpusów

- Test edytora korpusów korzysta z uchwytu przeciągania i nowych stref upuszczania.

## [2026-11-19] Poprawione przeciąganie korpusów

- Dodano uchwyt do przeciągania i ustalanie miejsca upuszczenia po pozycji kursora lub palca.

## [2026-11-19] Aktualizacja oczekiwań testów ustawień

- Dopasowano testy E2E do krótszej etykiety ustawień.

## [2026-11-19] Krótsza etykieta ustawień

- Zmieniono polską etykietę sekcji ustawień na „Ustawienia”.

## [2026-11-19] Porządki dokumentacji i testy reguł Firestore

- Zaktualizowano instrukcje uruchamiania testów, usunięto nieaktualną dokumentację widoków i dodano osobny cel testów reguł Firestore.

## [2026-11-19] Polskie tłumaczenie hodowli matek

- Przetłumaczono formularze, statusy, terminy i akcje w widoku hodowli matek.

## [2026-11-19] Poprawione testy E2E hodowli matek

- Dostosowano asercje i selektory scenariuszy hodowli matek do polskich tłumaczeń interfejsu.

## [2026-11-19] Testy E2E w obu językach

- Dodano angielski wariant testu list pasieczysk, poprawiono polskie asercje i ustabilizowano selektory akcji niezależnie od tłumaczeń.

## [2026-11-19] Dokończenie tłumaczeń widoków

- Przetłumaczono etykiety, podpowiedzi, osie czasu, historię i okna dialogowe szczegółów uli, ulików oraz pasieczysk.
- Przekazano aktywne tłumaczenia do nawigacji, powiadomień, okien dialogowych i widoku hodowli matek.

## [2026-11-19] Kontynuacja tłumaczeń widoków

- Zastąpiono część polskich podpowiedzi przycisków akcji uli i ulików wspólnymi tłumaczeniami.
- Ujednolicono etykietę pozycji hodowli matek w nawigacji z aktywnym językiem.

## [2026-11-19] Tłumaczenie ustawień aplikacji

- Dodano tłumaczenia polskie i angielskie etykiet, opisów, podpowiedzi i pól konfiguracji na ekranie ustawień.

## [2026-11-19] Tłumaczenie listy pasiek

- Przeniesiono etykiety stanów, podsumowania uli i podpowiedzi na liście pasiek do wspólnego modułu tłumaczeń.

## [2026-11-19] Przekazanie tłumaczeń do ekranów szczegółów

- Przekazano aktywny rekord tłumaczeń do ekranów uli, ulików weselnych, trutowiska i listy uli oraz przetłumaczono ich podstawowe akcje i nawigację.

## [2026-11-19] Typowany wybór języka aplikacji

- Dodano typ `Language`, centralne tłumaczenia PL/EN, selector ustawień oraz trwałość języka w localStorage i ustawieniach użytkownika.
- Dodano testy Elm i E2E dla kompletności tłumaczeń, dekodowania języka oraz zachowania po odświeżeniu i ponownym logowaniu.

## [2026-11-19] Stabilizacja testów przełączników pasiek

- Ustabilizowano dwa testy E2E przełączania modułów pasieczysk i doprecyzowano wybór przycisku nawigacji.

## [2026-11-19] Filtr ulików wymagających akcji

- Dodano propozycję OpenSpec dla opcjonalnego filtrowania ulików weselnych, których termin przypada dziś lub już minął.

## [2026-11-19] Alerty na poziomie trutowisk

- Dodano propozycję OpenSpec dla wykrzyknika przy trutowisku z listą nazw ulików wymagających natychmiastowej akcji.

## [2026-11-19] Specyfikacja sortowania drag-and-drop

- Dodano zmianę OpenSpec opisującą zastąpienie strzałek przeciąganiem i upuszczaniem dla pasiek, uli towarowych i ulików weselnych.

## [2026-11-19] Menu górne dopasowane do języka i układu

- Przeniesiono hamburger na lewą stronę górnego paska, ułożono pozycje menu pionowo i przeniesiono do niego ustawienia oraz wylogowanie.
- Etykiety menu zmieniają się zgodnie z wybranym językiem.

## [2026-11-19] Wybór języka i zwinięte sekcje ustawień

- Dodano wybór polskiego lub angielskiego języka z zapisem preferencji w ustawieniach użytkownika i przeglądarce.
- Ustawiono domyślne zwijanie sekcji ustawień.

## [2026-11-19] Tłumaczenie ustawień hodowli matek

- Przetłumaczono opisy, przełącznik i etykiety pól sekcji hodowli matek na język polski.

## [2026-11-19] Polska nazwa sekcji hodowli matek

- Zmieniono nagłówek sekcji Queen Rearing w ustawieniach na „Hodowla matek”.

## [2026-11-19] Katalog TODO na pomysły

- Dodano katalog `TODO/` jako lokalne brudnopisy (pominięty przez git via `.gitignore`)
- Przeniesiono opis zadania `firebase_environments.md` do `TODO/`

## [2026-11-19] Collapsible settings sections

- Added `SettingsSection` union type and `expandedSettingsSections` field to `Model`; all sections start expanded by default.
- Each section heading in Settings is now a clickable toggle button with a ∨/∧ chevron icon and `aria-expanded` attribute.
- Added `ToggleSettingsSection` message handled in `Main.elm` to collapse/expand individual sections.
- Updated `openspec/specs/settings-and-user/spec.md` with collapsible-sections requirements.
- Added two Playwright E2E scenarios covering default-expanded state and collapse/expand behaviour.

## [2026-11-19] Archive queen rearing and apiary navigation

- Synced the apiary views, main navigation, queen rearing, settings, and CI deltas into the main specs and archived the completed change.

## [2026-11-19] Powrót do aktualnego trutowiska uliku

- Zachowano identyfikator trutowiska przy wczytywaniu uliku z Firestore, aby powrót z linku NFC prowadził do jego obecnego miejsca.

## [2026-11-19] Ujednolicone kontrolki ustawień

- Dodano integrację Tailwind z Vite oraz wspólne style pól liczbowych i przełączników modułów w ustawieniach.

## [2026-11-19] Jednowierszowe przełączniki pasiek

- Przeniesiono checkboxy pasieki towarowej i trutowiska do jednego wiersza z ich etykietami.

## [2026-11-19] Navigation and voice fixes

- Synced current-apiary back navigation and commercial-hive voice dictation behavior into the main specs; added E2E coverage for relocation navigation and dictated note text.

## [2026-11-19] Filtr ulików wymagających akcji

- Dodano checkbox filtrujący uliki weselne według terminów przypadających dziś lub wcześniej oraz stanu bezmatek.
- Dodano stan pustego wyniku i testy Elm oraz Playwright.

## [2026-11-19] Self-service account deletion proposal

- Added an OpenSpec proposal for confirmed account deletion, including Firebase Authentication and associated Firestore data.

## [2026-11-20] Przeciąganie i upuszczanie kolejności

- Dodano trwałe przeciąganie pasiek, uli i ulików weselnych z zachowaniem elementów ukrytych filtrem oraz testy Elm i E2E.

## [2026-11-20] Naprawa testów E2E

- Testy aplikacji akceptują niezbędną pamięć, a sortowanie uli zachowuje osobną kolejność dla każdej pasieki.

## [2026-11-21] Ujednolicenie stylu przycisków

- Przyciski dodawania, zapisywania i przenoszenia ulika otrzymały wspólny styl akcji z widoku hodowli matek.

## [2026-11-21] Styl przycisku kopiowania NFC

- Przyciski kopiowania linku NFC mają teraz ten sam żółty styl co „Zaopalitkuj”.

## [2026-11-21] Pionowy formularz nowej serii matek

- Pola i przycisk tworzenia serii w widoku Hodowla matek są teraz ułożone jeden pod drugim.

## [2026-11-21] Oś czasu harmonogramu hodowli matek

- Ustawienia hodowli matek pokazują oś czasu z opisem dnia przekładania, przeniesienia do startera, izolacji i wygryzienia.
