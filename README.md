# BeeLog (PszczeliGłos / BeeTap)

[![Pokrycie testami Elm](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/aleklisi/BeeLog/main/coverage/coverage-badge.json)](https://github.com/aleklisi/BeeLog/actions/workflows/ci.yml)

BeeLog to nowoczesna, progresywna aplikacja internetowa (PWA) przeznaczona do kompleksowego zarządzania gospodarką pasieczną, pasieczyskami, ulami produkcyjnymi, trutowiskami oraz hodowlą matek pszczelich w terenie. Aplikacja została zaprojektowana z myślą o szybkiej pracy przy ulu, wspierając fizyczne tagi NFC oraz dyktowanie głosowe notatek (Speech-to-Text).

---

## 🛠️ Stos Technologiczny

* **Frontend:** Elm (architektura Model-View-Update, gwarantująca pełne bezpieczeństwo typów i brak błędów runtime typu `null`/`undefined`).
* **Narzędzia budowania i HMR:** Vite + `vite-plugin-elm` + Tailwind CSS.
* **Backend i Baza Danych:** Firebase (Cloud Firestore z regułami autoryzacji per właściciel, Firebase Authentication z Google Sign-In, Hosting).
* **Testy i Jakość:** Elm Test (`elm-test`), Playwright (testy E2E), walidacja specyfikacji OpenSpec.
* **Interfejs PWA:** Pełne wsparcie dla urządzeń mobilnych (Android / iOS) oraz przeglądarek stacjonarnych, obsługa trybu ciemnego (Dark Mode).

---

## ✨ Dostępna Funkcjonalność (OpenSpec)

Całość dotychczasowej funkcjonalności została sformalizowana w specyfikacji **OpenSpec**:

### 1. 🧭 Nawigacja i Architektura Modułowa (`main-navigation`, `apiary-views`)
* **Menu główne (hamburger):** Wygodna nawigacja dotykowa i klawiaturowa ze statusem dostępności dla czytników ekranu (a11y).
* **Niezależne moduły:** Możliwość niezależnego włączania i wyłączania widoków: *Pasieki towarowe*, *Pasieki weselne* oraz *Wychów matek*. Ukrycie modułu nie powoduje usunięcia powiązanych z nim danych.
* **Inteligentne przekierowania:** W przypadku wyłączenia w ustawieniach modułu, w którym użytkownik aktualnie przebywa, aplikacja automatycznie przekierowuje do innego aktywnego widoku lub Ustawień.
* **Rozdzielone widoki pasiek:** Dedykowane ekrany dla pasiek towarowych i trutowisk, co zapobiega pomyłkom i jednoznacznie przypisuje właściwy typ przy tworzeniu nowej pasieki.
* **Stały dostęp:** Sekcje Ustawienia oraz Wylogowanie są zawsze dostępne w menu głównym.

### 2. 🍯 Pasieki Towarowe i Ule Produkcyjne (`hives`, `commercial-hive-ordering`, `apiary-ordering`)
* **Konfiguracja struktury ula:** Elastyczny model pionowy ula (korpusy, półnadstawki, dennice, powałki, daszki) z przejrzystą reprezentacją graficzną.
* **Edycja korpusów i ramek:** Wybór typu korpusu, liczby i rodzaju ramek (zgodnie ze spersonalizowaną konfiguracją użytkownika).
* **Śledzenie matki i kraty odgrodowej:** Ewidencja obecności matki, koloru/roku opalitka, numeru matki oraz umiejscowienia kraty odgrodowej w ulu.
* **Historia przeglądów:** Rejestracja inspekcji i zdarzeń przy ulu z konfigurowalnym limitem historii.
* **Notatki głosowe (Speech-to-Text):** Szybkie dyktowanie notatek do ula w terenie przy użyciu Web Speech API.
* **Przeciąganie kafelków (Drag & Drop):** Intuicyjne przestawianie kolejności pasieczysk oraz uli w ramach danego pasieczyska z trwałym zapisem kolejności.

### 3. 🐝 Pasieki Weselne i Trutowiska (`mating-apiaries`, `mating-hive-ordering`)
* **Cykl życiowy matki w uliku weselnym:** Obsługa kluczowych stanów biologicznych:
  * `(B)` – **Bezmatek** (rodzina bez matki)
  * `(M)` – **Matecznik** (podany matecznik na wygryzieniu)
  * `(N)` – **Matka nieunasienniona** (wygryziona, w trakcie lotów godowych)
  * `(UNC)` – **Matka unasienniona** (unasienniona i czerwiąca)
* **Kalkulator terminów i oś czasu:** Automatyczne wyznaczanie spodziewanej daty wygryzienia oraz unasiennienia (+10 dni, konfigurowalne od 1 do 30 dni). Monitorowanie granicznego 30-dniowego terminu od wygryzienia na unasiennienie matki.
* **System alertów i podsumowań (Attention Alerts):**
  * Oznaczenie czerwonym wykrzyknikiem ulików wymagających natychmiastowej reakcji (zaległy termin wygryzienia lub unasiennienia, bezmatek, przekroczenie 30 dni).
  * Zagregowane ostrzeżenie na karcie trutowiska prezentujące listę wszystkich ulików wymagających uwagi w dymku (tooltip) oraz dla czytników ekranu.
* **Filtrowanie ulików:** Filtrowanie według stanów `(B)`, `(M)`, `(N)`, `(UNC)` oraz filtr `Tylko wymagające akcji` (pokazujący uliki z zaległymi/dzisiejszymi terminami oraz bezmatki).
* **Drag & Drop:** Zmiana kolejności ulików weselnych na trutowisku z pełnym zachowaniem spójności przy aktywnym filtrowaniu.

### 4. 👑 Moduł Wychowu Matek Pszczelich (`queen-rearing`)
* **Zarządzanie zasobami hodowlanymi:** Ewidencja matek reprodukcyjnych (rasa, linia, kolor, numer), rodzin starterowych (`PUSTY` / `ZAJETY`, licznik zrealizowanych serii), rodzin wychowujących (finisherów) oraz cieplarek (inkubatorów).
* **Unikalne numerowanie serii:** Atomowe nadawanie unikalnych rocznych numerów serii hodowlanych w formacie `YYYY/NN`.
* **Cykl serii hodowlanej:** Pełna obsługa etapów: `ZAPLANOWANA` ➔ `W_STARTERZE` ➔ `W_FINISHERZE` ➔ `W_CIEPLARCE` (lub bezpośrednie zakończenie z finishera) ➔ `ZAKONCZONA`.
* **Wyłączna rezerwacja zasobów:** Blokada jednoczesnego przypisania tego samego startera/finishera do wielu aktywnych serii i automatyczne zwalnianie z inkrementacją licznika po zakończeniu etapu.
* **Obsługa serii bez przyjęć:** Możliwość zakończenia serii bez przyjętych mateczników bezpośrednio z poziomu startera.
* **Priorytetyzacja według pilności:** Automatyczne sortowanie serii według najbliższego wymaganego działania z oznaczeniem kolorystycznym (czerwony – przeterminowane, żółty – wymagane w ciągu 24h, zielony – w terminie).
* **Harmonogram w strefie czasowej użytkownika:** Domyślna liczba przekładanych larw, czas w starterze, dzień izolacji i dzień spodziewanego wygryzienia.

### 5. 🏷️ Tagi NFC i Narzędzia Terenowe (`nfc-and-data`)
* **Integracja Web NFC API:** Bezpośredni odczyt i przypisywanie fizycznych tagów NFC zamontowanych na ulach towarowych oraz ulikach weselnych.
* **Linki NFC:** Generowanie i kopiowanie linków umożliwiających błyskawiczne otwarcie karty ula w terenie po zbliżeniu telefonu do tagu.

### 6. ⚙️ Ustawienia, Bezpieczeństwo i Samodzielne Usuwanie Konta (`settings-and-user`, `account-deletion`, `firestore-access-control`)
* **Niezależnie zwijane sekcje ustawień:** Przejrzysta konfiguracja podzielona na 4 sekcje (*Ogólne*, *Pasieki towarowe*, *Pasieki weselne*, *Wychów matek*) z dymkami pomocy.
* **Wielojęzyczność (i18n):** Pełne wsparcie dla języka polskiego i angielskiego (interfejs, etykiety, komunikaty i podpowiedzi).
* **Kontrola dostępu Firestore:** Ścisła ochrona prywatności danych – reguły bazy Firestore zezwalają na operacje wyłącznie uwierzytelnionemu właścicielowi (`adminId == request.auth.uid`), z blokadą współdzielenia danych i dziedziczeniem uprawnień przez podkolekcje uli.
* **Samodzielne usuwanie konta (Self-Service Account Deletion):** Bezpieczne usunięcie konta z poziomu Ustawień po podaniu dokładnej frazy potwierdzającej `Tak, usuwam konto!`. Całkowite czyszczenie danych (Firebase Auth, profil, ustawienia, serie wychowu, pasieki, ule, notatki) bezpośrednio przez Firebase Client SDK.

---

## 🔮 Planowana Funkcjonalność (OpenSpec Roadmap)

Funkcjonalności aktualnie projektowane i specyfikowane w OpenSpec:

### 1. 🛡️ Polityka Prywatności, Zgody Cookies i RODO (`privacy-and-consent`)
* **Informacje o ochronie danych osobowych:** Dedykowane okno dialogowe polityki prywatności dostępne z poziomu ekranu logowania oraz z Ustawień w języku polskim i angielskim.
* **Klauzula informacyjna RODO/GDPR:** Przejrzysty opis przetwarzania danych, okresów retencji oraz praw użytkownika (w tym prawa do bycia zapomnianym i skargi do PUODO).
* **Baner zgód dla nowych użytkowników:** Informacja o niezbędnej pamięci lokalnej przeglądarki (essential storage) oraz opcjonalnej analityce lub diagnostyce.
* **Panel zarządzania prywatnością w Ustawieniach:** Możliwość weryfikacji i zmiany zapisanych preferencji w dowolnym momencie (zapis w `localStorage`).

### 2. 🧪 Zaawansowane Scenariusze Testowe i Raportowanie (`add-comprehensive-tests`, `comprehensive-test-scenarios`)
* **Rozszerzenie testów E2E w Playwright:** Dalsza automatyzacja weryfikacji ścieżek użytkownika (w tym zaawansowane przemieszczanie ulików, walidacja formularzy, testy motywu ciemnego i responsywności mobilnej).
* **Zagregowane raportowanie pokrycia testami:** Automatyczne zbieranie metryk pokrycia kodu testami jednostkowymi i integracyjnymi.

### 3. 🌐 Izolacja Środowisk Firebase (`firebase_environments`)
* Rozdzielenie konfiguracji i baz Firestore pomiędzy środowiskiem deweloperskim / stagingowym a produkcją.

---

## 🚀 Uruchomienie Lokalne

1. Zainstaluj zależności:
   ```bash
   npm install
   ```
2. Uruchom serwer deweloperski z HMR:
   ```bash
   npm run dev
   ```
3. Otwórz w przeglądarce: `http://localhost:3000`

---

## 🧪 Uruchomienie Testów

Wszystkie testy w projekcie uruchamiane są za pośrednictwem narzędzia `make`:

```bash
make elm_test       # Testy jednostkowe Elm
make e2e_test       # Testy end-to-end Playwright
make test_openspec  # Ścisła walidacja specyfikacji OpenSpec
make all_test       # Pełny zestaw testów (Elm + Playwright + OpenSpec)
```
