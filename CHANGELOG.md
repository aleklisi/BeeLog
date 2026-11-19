# Changelog

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
