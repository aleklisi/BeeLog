# Design: Zarządzanie zasobami wychowu matek pszczelich

## Architecture & UI Guidelines
Przed napisaniem kodu Elm należy sprawdzić istniejące widoki (szczególnie panel Ustawień oraz widoki Uli/Pasieczysk), aby użyć dokładnie tych samych komponentów/klas dla zwijanych sekcji (`accordion`/`collapsible`), przycisków, inputów i badge'y kolorów opalitka.

### 4.1. Nagłówek widoku głównego „Hodowla matek”
- Przycisk „Ustawienia” w prawym górnym rogu nagłówka jest usuwany.
- Zastąpiony przyciskiem „Zasoby” otwierającym dedykowany widok zarządzania zasobami.

### 4.2. Widok „Zarządzanie zasobami” (3 zwijane karty)
1. **Matki reproduktorki** (numer ula, rasa i linia z ustawień pasieki, kolor opalitka, numer na opalitku).
2. **Startery** (numer ula).
3. **Finishery** (numer ula).

Wszystkie sekcje wykorzystują spójny układ kartowy w Tailwind CSS z pełnym wsparciem dla trybu ciemnego (`dark:`).
