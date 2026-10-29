# Plan Implementacji Aplikacji Pasiecznej (BeeTap / PszczeliGłos)

Kompleksowy plan architektoniczny i wdrożeniowy webowej aplikacji mobilnej (PWA) przeznaczonej do zarządzania pasieką, odczytu tagów NFC z uli oraz dyktowania notatek w terenie.

---

## 1. Przegląd Wymagań i Architektura

### 1.1 Wymagania Funkcjonalne
* **Struktura danych:** 
  * Pasieka podzielona na Pasieczyska, a te na Ule.
  * Ule zawierają: typ ramki, dane matki pszczelej (obecność opalitka, jego kolor oraz numer; brak opalitka klasyfikowany jako „czarny opalitek”) oraz zestaw notatek historycznych.
* **Obsługa w terenie:**
  * Odczyt fizycznych tagów NFC zamontowanych na ulach w celu natychmiastowego otwarcia karty danego ula.
  * Dyktowanie głosowe notatek (Speech-to-Text) powiązanych bezpośrednio z ulem.
* **Zarządzanie uprawnieniami (IAM):**
  * Każda pasieka posiada administratora.
  * Administrator może udostępniać i cofać dostęp do pasieki innym użytkownikom.
  * Użytkownik ze współdzielonym dostępem posiada pełne uprawnienia do edycji pasieki i jej składowych.

### 1.2 Stos Technologiczny
* **Frontend:** Elm (czysta architektura MVU, brak błędów typu `null/undefined`).
* **Przeglądarkowe API Interop (JavaScript Ports):** Web NFC API (`NDEFReader`), Web Speech API (`SpeechRecognition`).
* **Backend / Database / Hosting:** Firebase (Firestore, Authentication, Hosting) – 100% w darmowym planie Spark.
* **Standard:** PWA (Progressive Web App) z obsługą systemów Android oraz iOS (Safari / Web App).

---

## 2. Architektura Bazy Danych (Firestore)

Struktura bazuje na zagnieżdżonych kolekcjach, co ułatwia zarządzanie i izolowanie danych.

```text
/apiaries/{apiaryId}
  ├── adminId: "uid_administratora"
  ├── editors: ["uid_administratora", "uid_edytora_1", "uid_edytora_2"]
  ├── name: "Pasieka Główna"
  └── /yards/{yardId}
        ├── name: "Pasieczysko Leśne"
        └── /hives/{hiveId}
              ├── nfcTagId: "04:A2:8B:12:34:56:78"
              ├── frameType: "Dadant"
              ├── queen: {
              │     hasOpalit: true,
              │     color: "żółty",
              │     number: "42"
              │   }
              └── /notes/{noteId}
                    ├── text: "Silna rodzina, przełożono nadstawkę."
                    ├── authorId: "uid_użytkownika"
                    └── timestamp: ServerTimestamp
```

---

## 3. Reguły Bezpieczeństwa (Firestore Security Rules)

Plik `firestore.rules` odpowiadający za zabezpieczenie pasieki przed nieuprawnionym dostępem:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Funkcja pomocnicza sprawdzająca, czy użytkownik jest na liście edytorów
    function isEditor(apiaryData) {
      return request.auth != null && (request.auth.uid in apiaryData.editors);
    }

    match /apiaries/{apiaryId} {
      allow read, write: if request.auth != null && (request.auth.uid == resource.data.adminId || isEditor(resource.data));
      
      match /yards/{yardId} {
        allow read, write: if request.auth != null && isEditor(get(/databases/$(database)/documents/apiaries/$(apiaryId)).data);
        
        match /hives/{hiveId} {
          allow read, write: if request.auth != null && isEditor(get(/databases/$(database)/documents/apiaries/$(apiaryId)).data);
          
          match /notes/{noteId} {
            allow read, write: if request.auth != null && isEditor(get(/databases/$(database)/documents/apiaries/$(apiaryId)).data);
          }
        }
      }
    }
  }
}
```

---

## 4. Architektura Portów w Elm (JS Interop)

Ze względu na specyfikę języka Elm, komunikacja z Firebase, NFC oraz dyktowaniem głosu odbywa się poprzez porty.

### 4.1 Schemat Komunikacji

```text
+-----------------+     Port Out     +-----------------------------------+
|                 | -------------->  |                                   |
|   Aplikacja     |                  |   Plik JavaScript (index.js)      |
|     ELM         |                  |   - Firebase SDK v10              |
|   (Model-View-  |     Port In      |   - Web NFC API (NDEFReader)      |
|    Update)      | <--------------  |   - Web Speech API                |
+-----------------+                  +-----------------------------------+
```

### 4.2 Przykład definicji portów w Elm (`Ports.elm`)

```elm
port module Ports exposing (..)

-- Wysyłanie poleceń do JavaScript
port scanNfcTrigger : () -> Cmd msg
port startVoiceRecognition : () -> Cmd msg
port saveNoteToFirestore : { apiaryId : String, yardId : String, hiveId : String, text : String } -> Cmd msg

-- Odbieranie danych z JavaScript
port nfcTagScanned : (String -> msg) -> Sub msg
port voiceTextReceived : (String -> msg) -> Sub msg
port firestoreNoteSaved : (Bool -> msg) -> Sub msg
```

---

## 5. Etapy Implementacji

### Faza 1: Konfiguracja Środowiska i Firebase
1. Utworzenie projektu w konsoli Firebase.
2. Włączenie **Firebase Authentication** (Email/Password & Google Sign-In).
3. Inicjalizacja **Cloud Firestore** i wdrożenie reguł bezpieczeństwa.
4. Konfiguracja pliku `manifest.json` oraz ikonek dla aplikacji PWA.

### Faza 2: Implementacja Frontendu w Elm
1. Stworzenie sz