# Specyfikacja Frontendu: Podgląd Pasieczyska, Karta Ula i Dyktowanie Notatek

Dokument zawiera szczegółową specyfikację interfejsu użytkownika (UI) oraz logiki aplikacyjnej dla widoku listy uli na danym pasieczysku, karty pojedynczego ula, obsługi tagów NFC oraz notatek tekstowych i głosowych.

---

## 1. Widok Pasieczyska (Lista Uli)

Po przejściu z głównego ekranu do wybranego pasieczyska użytkownik widzi listę znajdujących się na nim uli.

### 1.1 Elementy Widoku Listy
* **Nagłówek:** Nazwa wybranego pasieczyska oraz przycisk powrotu (`← Powrót do pasieczysk`).
* **Przycisk Akcji:** `+ Dodaj nowy ul` do pasieczyska.
* **Szybkie Skanowanie:** Przycisk `📷 / 📶 Skanuj NFC` pozwalający od razu zeskanować tag ula bez ręcznego szukania na liście.
* **Elementy Listy Uli:**
  * Każdy ul prezentowany jest jako kafelek lub wiersz zawierający czytelną **nazwę lub numer ula** (np. *Ul #04*, *Ul przy Lipie*).
  * Szybki podgląd informacji: typ ramki oraz kolor opalitka matki (np. znacznik wizualny w danym kolorze).
  * **Kliknięcie w ul:** Kliknięcie w dowolne miejsce kafelka otwiera pełny widok karty szczegółowej danego ula.

---

## 2. Szczegółowy Widok Kafelka Ula (Karta Ula)

Widok szczegółowy ula prezentuje pełne dane o danej rodzinie pszczelej i sprzęcie. Wszystkie pola informacyjne posiadają opcję **niezależnej edycji (pole po polu)**.

### 2.1 Informacje o Pszczołach i Sprzęcie

1. **Nazwa / Numerek Ula:**
   * Identyfikator ula na pasieczysku.
   * Dedykowany przycisk edycji / ikona ołówka obok nazwy.

2. **Matka Pszczela:**
   * **Rasa:** np. *Krainka (Apis mellifera carnica)*, *Buckfast*.
   * **Linia:** np. *Sklenar*, *Meteora*, *Nieska*.
   * **Opalitek - Kolor i Numer:**
     * Wybór koloru z oficjalnej palety pszczelarskiej (*Biały*, *Żółty*, *Czerwony*, *Zielony*, *Niebieski*).
     * Opcja oznaczenia braku opalitka / „czarny opalitek”.
     * Numer umieszczony na opalitku (pole liczbowe/tekstowe).
   * *Uwaga:* Każdy z atrybutów matki (rasa, linia, opalitek) można edytować i zapisać niezależnie od reszty danych.

3. **Sprzęt / Konstrukcja:**
   * **Rodzaj ula / typ ramki:** np. *Wielkopolski 10-ramkowy*, *Dadant*, *Ostrowskiej*, *Warszawski poszerzany*.

---

## 3. Integracja NFC oraz Notatki (Tekst i Głos)

### 3.1 Powiązanie z Tagiem NFC
* W karcie ula znajduje się dedykowany przycisk: **`🔗 Przypisz / Zmień tag NFC`**.
* Po kliknięciu uruchamia się odczyt czytnika NFC w telefonie.
* Przyłożenie fizycznego tagu NFC zapisuje jego unikalny identyfikator (`UID`) bezpośrednio w dokumencie tego ula w bazie Firestore.
* W przypadku powodzenia wyświetla się komunikat potwierdzający prawidłowe przypisanie tagu.

### 3.2 Moduł Notatek i Dyktowania Głosowego

1. **Formularz Wprowadzania Notatki:**
   * **Pole Tekstowe (`Textarea`):** Umożliwia ręczne wpisanie treści notatki z klawiatury.
   * **Przycisk Mikrofonu (`🎤 Dyktuj`):**
     * Kliknięcie uruchamia moduł dyktowania (przeglądarkowe Web Speech API).
     * Wypowiadane słowa zamieniane są na tekst i wstawiane w czasie rzeczywistym do pola notatki.
   * **Przycisk `Zapisz Notatkę`:** Dodaje nową notatkę z podanym tekstem, aktualnym czasem (`timestamp`) oraz identyfikatorem autora.

2. **Historia Wpisów (Poprzednie Notatki):**
   * Poniżej formularza znajduje się chronologiczna lista historycznych notatek ula (od najnowszych do najstarszych).
   * Każda notatka zawiera:
     * Treść wpisu.
     * Datę i godzinę utworzenia.
     * Imię/E-mail autora wpisu (przydatne przy współdzieleniu pasieki z innymi użytkownikami).