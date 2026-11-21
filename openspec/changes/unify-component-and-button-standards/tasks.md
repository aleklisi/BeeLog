# Tasks

## 1. Wspólny język komponentów

- [ ] 1.1 Zinwentaryzuj powtarzające się style przycisków i komponentów w głównych widokach, przypisz je do ról z `ui-component-standards` i zweryfikuj kompletność mapowania w dokumencie roboczym zmiany.
- [ ] 1.2 Dodaj współdzielone style dla wariantów przycisków, formularzy, kart, nagłówków sekcji i grup akcji; uruchom `make test_openspec` i sprawdź widok referencyjny w motywie jasnym i ciemnym.
- [ ] 1.3 Dodaj lub zaktualizuj testy komponentów dla wariantów, fokusu i dostępnego stanu; uruchom właściwy cel `make` i potwierdź obsługę klawiaturą.

## 2. Migracja formularzy i ustawień

- [ ] 2.1 Zastosuj wspólne warianty i układ akcji w ustawieniach oraz formularzach; sprawdź spójność pól i przycisków we wszystkich sekcjach oraz językach.
- [ ] 2.2 Zaktualizuj testy widoków ustawień/formularzy dla hierarchii akcji i semantycznych kolorów; uruchom odpowiedni cel `make`.
- [ ] 2.3 Uzgodnij plan i zakres `settings-buttons-color-guidelines` z docelowym standardem, zachowując jego wymagania kolorystyczne; zweryfikuj spójność specyfikacji przez `make test_openspec`.

## 3. Migracja list, szczegółów i dialogów

- [ ] 3.1 Zastosuj wspólne style i rozmieszczenie akcji w listach, szczegółach, kartach i dialogach, zachowując kolory znaczące dla stanów domenowych; sprawdź widoki w szerokim i wąskim układzie.
- [ ] 3.2 Zaktualizuj testy E2E lub widoków dla akcji elementów, usuwania i zawijania grup na małym ekranie; uruchom odpowiedni cel `make`.
- [ ] 3.3 Uzgodnij `commercial-apiary-hive-button-colors` ze wspólnymi rolami przycisków i sprawdź specyfikacje przez `make test_openspec`.

## 4. Integracja

- [ ] 4.1 Usuń zastąpione lokalne kombinacje stylów i przejrzyj zmigrowane widoki pod kątem wyjątków domenowych; potwierdź brak niespójnych wariantów w przeglądzie kodu.
- [ ] 4.2 Uruchom `make all_test` i `make test_openspec`; potwierdź poprawne działanie scenariuszy klawiatury, motywów i układu mobilnego.
