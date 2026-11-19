# Tasks

## 1. Wspólny mechanizm przeciągania i zapisu kolejności

- [ ] 1.1 Rozszerzyć model i komunikaty Elm o identyfikator przeciąganego elementu, typ kolekcji oraz obsługę rozpoczęcia, zakończenia, przeciągania nad celem i upuszczenia; zweryfikować kompilacją aplikacji, że wszystkie nowe komunikaty mają obsługę.
- [ ] 1.2 Dodać funkcje przenoszenia elementu przed lub za celem po stabilnym ID oraz normalizacji pól `order`; zweryfikować testami Elm przypadki przeniesienia na początek, środek, koniec, upuszczenia na siebie i nieprawidłowego celu.
- [ ] 1.3 Zachować istniejącą persystencję kolejności i obsłużyć brakujące lub powtarzające się wartości `order` przez kolejność listy jako fallback; zweryfikować testem Elm, że po zapisie kolejność jest deterministyczna.

## 2. Kolejność pasiek

- [ ] 2.1 Dodać atrybuty i zdarzenia drag-and-drop do kart pasiek w `Views.ApiaryList`, usunąć przyciski strzałek i zabezpieczyć nawigację oraz akcje karty przed uruchomieniem podczas przeciągania; zweryfikować testem Elm lub E2E obecność drag-and-drop i brak kontrolek strzałek.
- [ ] 2.2 Podłączyć upuszczenie pasieki do aktualizacji listy oraz zapisu istniejącego pola `order`; zweryfikować przez `make e2e_test` zmianę kolejności, powrót do widoku i odświeżenie.

## 3. Kolejność uli towarowych

- [ ] 3.1 Dodać drag-and-drop do kart uli w `Views.PasieczyskoTowarowe`, usunąć przyciski góra/dół i zachować niezależność akcji szczegółów, zmiany nazwy i usuwania; zweryfikować testem widoku brak strzałek oraz brak nawigacji po dropie.
- [ ] 3.2 Zastosować reorder wyłącznie do uli należących do bieżącej pasieki towarowej i zapisać ich `order`; zweryfikować przez `make e2e_test`, że kolejność i dane ula są zachowane po ponownym otwarciu, a inna pasieka nie zmienia kolejności.

## 4. Kolejność ulików weselnych

- [ ] 4.1 Dodać drag-and-drop do kart ulików w `Views.Trutowisko`, usunąć przyciski góra/dół i zachować niezależność wejścia w szczegóły oraz akcji przenoszenia, zmiany nazwy i usuwania; zweryfikować testem widoku brak strzałek.
- [ ] 4.2 Zaimplementować zapis kolejności ulików w obrębie konkretnego trutowiska, w tym scalanie kolejności widocznych elementów z elementami ukrytymi przez filtr stanu; zweryfikować testem Elm/E2E, że filtr nie zmienia względnej kolejności ani danych ukrytych ulików.

## 5. Weryfikacja integracyjna i dokumentacja

- [ ] 5.1 Zaktualizować scenariusze E2E obejmujące trzy listy, trwałość po odświeżeniu i brak uruchamiania akcji karty podczas dropu; zweryfikować poleceniem `make e2e_test`.
- [ ] 5.2 Uruchomić pełną walidację OpenSpec oraz testy projektu przez `make test_openspec` i `make all_test`, a wynik zapisać w podsumowaniu zmiany.
