# Change: Zarządzanie zasobami wychowu matek pszczelich

## Why
Obecny ekran „Hodowla matek” miesza zarządzanie zasobami (matkami reproduktorkami, starterami i finisherami) z planowaniem serii matek, a przycisk „Ustawienia” w nagłówku nie prowadzi do właściwej konfiguracji modułu. Wydzielenie dedykowanego widoku zarządzania zasobami z trzema zwijanymi sekcjami poprawi ergonomię pracy w pasiece i przygotuje czysty fundament pod rozbudowę planowania oraz obsługi pojedynczej serii matek.

## What Changes
- **Nagłówek widoku „Hodowla matek”:** usunięcie przycisku **„Ustawienia”** z prawego górnego rogu i zastąpienie go przyciskiem **„Zasoby”**.
- **Nowy widok „Zarządzanie zasobami”:** nawigacja z i powrót do głównego widoku „Hodowla matek”.
- **Trzy zwijane sekcje zasobów (CRUD dla każdej listy):**
  1. **Matki reproduktorki:** `numer ula`, `rasa i linia` (np. `car. Galicja`, `cau. M` – z listy linii skonfigurowanej w ustawieniach pasieki), `kolor opalitka`, `numer na opalitku`.
  2. **Startery:** `numer ula`.
  3. **Finishery:** `numer ula`.
- **Główny widok „Hodowla matek”:** oczyszczenie ekranu z formularzy i list zasobów przy zachowaniu dodawania, edycji i usuwania serii matek (szczegółowy widok pojedynczej serii poza zakresem tej zmiany).
- **Stylizacja UI:** spójny układ kartowy w Tailwind CSS ze wsparciem dla trybu ciemnego (`dark:`).

## Impact
- Affected specs: `queen-rearing-resources` (oraz ewentualna modyfikacja istniejącej specyfikacji modułu hodowli matek, jeśli istnieje w `openspec/specs/`).
- Affected code: frontend Elm (`src/` / `frontend/`), model stanu, widok hodowli matek, nowy widok zarządzania zasobami, integracja z ustawieniami linii pszczół oraz synchronizacja z Firestore.
