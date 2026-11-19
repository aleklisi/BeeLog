# Tasks

## 1. Wspólna logika i podsumowanie alertów

- [ ] 1.1 Udostępnić wspólną funkcję wyznaczającą aktywne powody alertu dla uliku oraz użyć jej zarówno w widoku uliku, jak i przy wyliczaniu alertowych ulików trutowiska; zweryfikować przez `make elm_test`, że dotychczasowe reguły i testy alertów nadal przechodzą.
- [ ] 1.2 Dodać funkcję zwracającą nazwy alertowych ulików w kolejności `apiary.uliki`, z pominięciem ulików bez aktywnego alertu; zweryfikować testami Elm przypadki: brak wyników, jeden wynik, wiele wyników oraz różne stany i daty.

## 2. Alert na karcie trutowiska

- [ ] 2.1 Dodać czerwony, fokusable wykrzyknik do karty trutowiska wyłącznie wtedy, gdy lista alertowych nazw nie jest pusta; umieścić listę nazw w `title` i `aria-label`, a kliknięcie nie może uruchamiać nawigacji karty; zweryfikować testem e2e przez `make e2e_test`.
- [ ] 2.2 Zachować istniejący wygląd i zachowanie kart pasiek towarowych oraz pojedynczych alertów przy ulikach; zweryfikować scenariusze braku alertu, alertu dla jednego uliku, wielu ulików i fokusu klawiaturą przez `make e2e_test`.

## 3. Walidacja zmiany

- [ ] 3.1 Uruchomić pełną walidację specyfikacji przez `make test_openspec` i poprawić ewentualne niespójności artefaktów.
