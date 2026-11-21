# Tasks

## 1. Ujednolicenie przycisków w Ustawieniach

- [ ] 1.1 Wprowadzić semantyczne style dla nawigacji, dodawania i przełączania motywu w widoku Ustawień; sprawdzić kontrast tekstu oraz stany `hover`/`focus` w obu motywach.
- [ ] 1.2 Ostylować przyciski zwijania i rozwijania sekcji jasnozielonym wariantem, zachowując pełną szerokość i `aria-expanded`; sprawdzić kontrast tekstu w obu motywach.
- [x] 1.3 Ostylować usuwanie i anulowanie czerwonym wariantem, również dla kompaktowych akcji ikonowych; sprawdzić rozróżnialność i czytelność w obu motywach.
- [ ] 1.4 Sprawdzić kontrolki preferencji: przycisk przełączania motywu ma rolę ciemnozielonej akcji, a wybór języka i przełączniki modułów pozostają natywnymi kontrolkami.
- [x] 1.5 Zaktualizować lub dodać testy UI dla ról kolorystycznych, fokusowania klawiaturą i motywów jasnego/ciemnego; uruchomić odpowiedni cel `make`.

## 2. Walidacja zmiany

- [ ] 2.1 Uruchomić `make test_openspec` i potwierdzić, że delta przechodzi walidację.
- [ ] 2.2 Obejrzeć panel Ustawień w motywie jasnym i ciemnym oraz sprawdzić kontrast, `hover` i `focus` nawigacji, akcji dodawania, przełącznika motywu, nagłówków sekcji i akcji destrukcyjnych.
