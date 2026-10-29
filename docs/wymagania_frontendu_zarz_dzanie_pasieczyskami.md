# Specyfikacja Frontendu: Ekran Logowania & Zarządzanie Pasieczyskami

Dokument zawiera szczegółową specyfikację interfejsu użytkownika (UI) oraz logiki aplikacyjnej (Elm Architecture) dla pierwszego modułu aplikacji: **Uwierzytelniania** oraz **Zarządzania Pasieczyskami**.

## 1. Ekran Logowania (Authentication Guard)

### 1.1 Zachowanie Aplikacji (Bariera Dostępu)

* **Status Niezalogowany:**
  * Jeśli użytkownik nie jest zalogowany, aplikacja **blokuje dostęp** do jakichkolwiek zasobów pasiecznych.
  * Wyświetlany jest wyłącznie formularz logowania / rejestracji.
  * Każda próba przejścia pod inny widok przekierowuje automatycznie do ekranu logowania.

* **Status Zalogowany:**
  * Po pomyślnym zalogowaniu użytkownik zostaje automatycznie przekierowany na widok główny (Pulpit pasieczysk).
  * W nagłówku aplikacji dostępny jest przycisk **"Wyloguj się"**.

### 1.2 Interfejs Logowania

* Logowanie e-mail / hasło.
* Przycisk szybkiego logowania kontem Google (Google Sign-In via Firebase Auth).
* Komunikaty błędów (np. błędne hasło, brak użytkownika) wyświetlane czytelnie pod formularzem.

---

## 2. Widok Główny: Lista Pasieczysk

Po zalogowaniu użytkownik widzi interfejs podzielony na dwie sekcje z kafelkami pasieczysk.

### 2.1 Podział Pasieczysk

1. **Moje Pasieczyska:**
   * Pasieczyska, dla których zalogowany użytkownik jest właścicielem/administratorem.
   * Pełny dostęp do zarządzania (dodawanie, edycja, usuwanie).

2. **Udostępnione Pasieczyska:**
   * Pasieczyska udostępnione użytkownikowi przez innych administratorów.
   * Widok kafelków z możliwością wejścia i edycji zawartości pasieczyska (zgodnie z przyznanymi uprawnieniami edytora).

---

## 3. Interakcja z Kafelkiem Pasieczyska

### 3.1 Nawigacja do Uli
* **Kliknięcie/Dotknięcie kafelka:** 
  * Kliknięcie w dowolne miejsce kafelka danego pasieczyska (poza ikonami akcji) powoduje **natychmiastowe przejście do listy uli** znajdujących się na tym konkretnym pasieczysku.
  * Nagłówek nowo otwartego widoku wyświetla nazwę wybranego pasieczyska oraz przycisk powrotu ("← Powrót do listy pasieczysk").

### 3.2 Elementy i Akcje na Kafelku

Każdy kafelek pasieczyska zawiera:
* **Nazwę pasieczyska** (główny element klikalny).
* **Licznik uli** (np. `12 uli`).
* **Ikonkę Ołówka (Edycja):**
  * Otwiera modal/formularz zmiany nazwy pasieczyska.
  * Po zatwierdzeniu nowa nazwa jest aktualizowana w Firestore.
* **Ikonkę Śmietnika (Usuwanie):**
  * Kliknięcie **nie usuwa** pasieczyska natychmiast.
  * Wyświetla modal z zapytaniem: *"Czy na pewno chcesz usunąć pasieczysko [Nazwa] wraz ze wszystkimi ulami i notatkami?"*.
  * Do wyboru przyciski: `Anuluj` oraz `Potwierdź usunięcie`.

---

## 4. Dodawanie Nowego Pasieczyska

* Nad listą "Moje Pasieczyska" znajduje się wyrazisty przycisk **"+ Dodaj Pasieczysko"**.
* Kliknięcie otwiera prosty formularz modalny:
  * Pole tekstowe: **Nazwa pasieczyska** (wymagane).
  * Przyciski: `Anuluj` oraz `Zapisz`.
* Po zapisaniu nowe pasieczysko pojawia się automatycznie na liście dzięki subskrypcji Firestore.