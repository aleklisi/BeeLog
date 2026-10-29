# Specyfikacja Frontendu: Udostępnianie Pasiek i Zarządzanie Dostępem

Dokument zawiera szczegółową specyfikację interfejsu użytkownika (UI) oraz logiki aplikacyjnej dla modułu zarządzania uprawnieniami, udostępniania pasiek innym użytkownikom z różnymi poziomami dostępu oraz cofania uprawnień.

## 1. Poziomy Uprawnień (Role)

W ramach danej pasieki wyróżniamy trzy poziomy dostępu:

1. **Właściciel / Administrator Pasieki:**
   * Twórca pasieki.
   * Ma pełny dostęp do odczytu i edycji wszystkich zasobów pasieki.
   * Posiada **wyłączne prawo do zarządzania dostępami** (dodawanie/usuwanie użytkowników, zmiana ich poziomu uprawnień).
   * Może usunąć całą pasiekę.

2. **Edytor (`Edit`):**
   * Posiada pełne prawo do odczytu oraz **modyfikacji danych**.
   * Może dodawać, edytować i usuwać ule, pasieczyska, informacje o matkach oraz notatki (głosowe i tekstowe).
   * **Nie może** dodawać ani usuwać innych użytkowników ani usuwać samej pasieki.

3. **Obserwator (`View only`):**
   * Posiada **wyłącznie prawo do odczytu** danych pasieki.
   * Może przeglądać listę pasieczysk, uli, parametry matek oraz czytać historię notatek.
   * Przycisk dodawania notatek, edycji pól czy przypisywania tagów NFC jest dla niego niewidoczny lub zablokowany.

---

## 2. Interfejs Zarządzania Dostępem (Dla Administratora)

Na karcie / w ustawieniach każdej pasieki, dla której zalogowany użytkownik jest Administratorem, widoczny jest przycisk **`👥 Udostępnij pasiekę`**.

### 2.1 Formularz Nadawania Dostępów

Kliknięcie przycisku otwiera modal / okno zarządcze:

1. **Pole e-mail:** Pole tekstowe do wpisania adresu e-mail użytkownika, któremu chcemy przyznać dostęp.
2. **Wybór poziomu dostępu (Radio / Dropdown):**
   * `Edycja` (*Dostęp do odczytu i wprowadzania zmian*)
   * `Tylko podgląd` (*Dostęp wyłącznie do odczytu danych*)
3. **Przycisk `Przyznaj dostęp`:**
   * Weryfikuje, czy użytkownik o danym adresie e-mail istnieje w systemie.
   * Zapisuje uprawnienie w bazie Firestore (dodaje użytkownika do odpowiedniej listy uprawnionych).

### 2.2 Lista Użytkowników z Dostępem

W oknie modalnym wyświetlana jest aktualna lista wszystkich osób mających dostęp do danej pasieki:

* **E-mail użytkownika** oraz jego aktualna rola (`Właściciel`, `Edytor`, `Obserwator`).
* **Zmiana roli (Dropdown):** Administrator może w dowolnym momencie zmienić poziom dostępu z `Tylko podgląd` na `Edycja` i odwrotnie.
* **Przycisk `Cofnij dostęp` (Ikonka śmietnika / X):**
  * Wyświetla zapytanie potwierdzające: *"Czy na pewno chcesz odebrać dostęp użytkownikowi [email]?"*.
  * Po potwierdzeniu usuwa identyfikator użytkownika z listy uprawnionych w Firestore.

---

## 3. Zmiany w Bazie Danych i Security Rules

### 3.1 Schemat Dokumentu Pasieki w Firestore

Dokument `/apiaries/{apiaryId}` przechowuje mapę / słownik uprawnień:

```json
{
  "name": "Pasieka Główna",
  "adminId": "uid_wlasciciela",
  "members": {
    "uid_wlasciciela": "owner",
    "uid_edytora": "edit",
    "uid_obserwatora": "view"
  }
}
```

### 3.2 Reguły Firestore (Firestore Security Rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function getRole(apiaryData) {
      return apiaryData.members[request.auth.uid];
    }

    function isOwner(apiaryData) {
      return request.auth != null && (request.auth.uid == apiaryData.adminId || getRole(apiaryData) == 'owner');
    }

    function canEdit(apiaryData) {
      return request.auth != null && (getRole(apiaryData) == 'owner' || getRole(apiaryData) == 'edit');
    }

    function canView(apiaryData) {
      return request.auth != null && (getRole(apiaryData) == 'owner' || getRole(apiaryData) == 'edit' || getRole(apiaryData) == 'view');
    }

    match /apiaries/{apiaryId} {
      allow read: if canView(resource.data);
      allow write: if canEdit(resource.data);
      allow delete, update: if isOwner(resource.data);

      match /{allSubcollections=**} {
        allow read: if canView(get(/databases/$(database)/documents/apiaries/$(apiaryId)).data);
        allow write: if canEdit(get(/databases/$(database)/documents/apiaries/$(apiaryId)).data);
      }
    }
  }
}
```