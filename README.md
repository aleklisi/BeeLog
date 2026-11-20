# BeeLog (PszczeliGłos / BeeTap)

[![Pokrycie testami Elm](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/aleklisi/BeeLog/main/coverage/coverage-badge.json)](https://github.com/aleklisi/BeeLog/actions/workflows/ci.yml)

BeeLog to nowoczesna, progresywna aplikacja internetowa (PWA) przeznaczona do kompleksowego zarządzania pasieką, pasieczyskami i ulami w terenie. Aplikacja wspiera czytanie tagów NFC z uli oraz dyktowanie głosowe notatek (Speech-to-Text).

## 🛠️ Stos Technologiczny
* **Frontend:** Elm (czysta architektura MVU, całkowity brak błędów typu `null/undefined`).
* **Narzędzia budowania i HMR:** Vite + `vite-plugin-elm`.
* **Backend & Baza Danych:** Firebase (Cloud Firestore, Authentication z Google Sign-In, Hosting).
* **Testy:** Elm Test (`elm-test`) oraz Playwright (E2E).
* **Interfejs PWA:** Wsparcie dla urządzeń mobilnych (Android / iOS) oraz przeglądarek desktopowych.

## ✨ Główne Funkcje
* **Zarządzanie pasieczyskami i ulami:** Tworzenie, edycja nazw, typów ramek, danych matek pszczelich (opalitek, kolor, numer) oraz usuwanie uli i pasiek.
* **Trutowiska i Uliki Weselne:** Prowadzenie ulików weselnych ze śledzeniem stanów oraz spodziewanych terminów wygryzienia i unasiennienia (+10 dni).
* **Stany ulików weselnych:** Obsługa nowych oznaczeń i stanów:
  * `(B)` – Bezmatek
  * `(M)` – Matecznik
  * `(N)` – Matka nieunasienniona
  * `(UNC)` – Matka unasienniona
* **Filtrowanie stanów ulików:** Filtrowanie ulików weselnych w widoku trutowiska według wybranych stanów `(B)`, `(M)`, `(N)`, `(UNC)`.
* **Panel Ustawień (Per Użytkownik):** Konfiguracja preferencji i enums aplikacji zapisywana indywidualnie dla każdego użytkownika w bazie Firebase (np. konfigurowalna lista rodzajów ramek dla pasieki towarowej).
* **Przenoszenie kafelków (Reordering):** Intuicyjna zmiana kolejności pasieczysk oraz uli.
* **Tagi NFC:** Przypisywanie i odczyt fizycznych tagów NFC zamontowanych na ulach za pomocą Web NFC API.
* **Dyktowanie głosowe notatek:** Szybkie notowanie w terenie przy użyciu Web Speech API.
* **Tryb Ciemny (Dark Mode):** Wygodna praca w terenie w różnych warunkach oświetleniowych.

## 🚀 Uruchomienie lokalne
1. Zainstaluj zależności:
   ```bash
   npm install
   ```
2. Uruchom serwer deweloperski:
   ```bash
   npm run dev
   ```
3. Otwórz w przeglądarce: `http://localhost:3000`

## 🧪 Uruchomienie testów
```bash
make elm_test       # testy Elm
make e2e_test       # testy Playwright
make test_openspec  # walidacja OpenSpec
make all_test       # pełny zestaw testów
```
