# Change: System kolorystyczny w odcieniach zieleni (Tailwind CSS) oraz spójne kolory stanów ulików weselnych z osią czasu

## Why
Interfejs wymaga ujednolicenia w zielonej palecie (z akcentami np. `green` i `lime`) z wyraźnym kontrastem tekstu na przyciskach i elementach UI w trybie jasnym oraz ciemnym (`dark:`), czerwonym wyróżnieniem akcji usuwania oraz pełną zgodnością wizualną przycisków zmiany stanów ulików weselnych z kolorami użytymi na osi czasu.

## What Changes
- Zdefiniowanie spójnych wariantów kolorystycznych opartych na Tailwind CSS (wsparcie trybu jasnego i ciemnego `dark:`) dla głównych przycisków, przycisków drugorzędnych, pól formularzy, odznak i powierzchni.
- Zapewnienie wysokiego kontrastu między tłem przycisku/elementu a jego tekstem (w tym unikanie niskiego kontrastu białego tekstu na jasnej limonkowej zieleni `lime`).
- Ujednolicenie przycisków usuwania w kolorze czerwonym (zarówno na listach, jak i przy akcjach destrukcyjnych/potwierdzeniu).
- Powiązanie wizualne przycisków zmiany stanów ulików weselnych — `(B)` Bezmatek, `(M)` Matecznik, `(N)` Matka nieunasienniona, `(UNC)` Matka unasienniona — z odpowiadającymi im kolorami z osi czasu oraz wyraźne oznaczenie aktywnego/wybranego stanu.

## Impact
- Affected specs: `ui-theme-colors`, `mating-hives`
- Affected code: frontend Elm (komponenty przycisków/UI, widok osi czasu i stanów ulików weselnych, style Tailwind CSS, testy `make test_openspec`, `make elm_test`, `make e2e_test`).