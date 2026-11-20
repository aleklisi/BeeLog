# Spec: Zarządzanie zasobami wychowu matek pszczelich

## ADDED Requirements

### Requirement: Nawigacja do zarządzania zasobami z widoku Hodowli matek
W nagłówku głównego widoku **Hodowla matek** przycisk **„Ustawienia”** po prawej stronie MUST zostać usunięty, a w jego miejsce MUST pojawić się przycisk/akcja **„Zasoby”** otwierająca widok zarządzania zasobami.

#### Scenario: Zamiana przycisku Ustawienia na Zasoby
- **WHEN** użytkownik otwiera główny widok **Hodowla matek**
- **THEN** w prawym górnym rogu nagłówka przycisk „Ustawienia” nie jest wyświetlany
- **AND** w prawym górnym rogu nagłówka widoczny jest przycisk „Zasoby”
- **AND** kliknięcie przycisku „Zasoby” przenosi użytkownika do widoku zarządzania zasobami

#### Scenario: Powrót z widoku zarządzania zasobami do Hodowli matek
- **WHEN** użytkownik znajduje się w widoku zarządzania zasobami i kliknie akcję powrotu
- **THEN** wraca do głównego widoku **Hodowla matek**, a wprowadzone wcześniej zmiany w zasobach są zachowane

---

### Requirement: Trzy zwijane sekcje w widoku Zarządzanie zasobami
Widok **Zarządzanie zasobami** MUST składać się z trzech zwijanych sekcji (zachowujących się analogicznie do zwijanych sekcji w ustawieniach):
1. **Matki reproduktorki**
2. **Startery**
3. **Finishery**

#### Scenario: Niezależne zwijanie i rozwijanie sekcji
- **WHEN** użytkownik kliknie nagłówek jednej z trzech sekcji („Matki reproduktorki”, „Startery” lub „Finishery”)
- **THEN** wybrana sekcja przełącza się pomiędzy stanem rozwiniętym a zwiniętym bez wpływu na stan rozwinięcia pozostałych sekcji

---

### Requirement: Zarządzanie listą matek reproduktorek
W sekcji **Matki reproduktorki** użytkownik MUST móc wyświetlać listę reproduktorek oraz dodawać, edytować i usuwać pozycje. Każda matka reproduktorka MUST posiadać następujące pola:
- **numer ula**
- **rasa i linia** (np. `car. Galicja` lub `cau. M`, powiązane z listą linii zdefiniowaną w ustawieniach pasieki)
- **kolor opalitka**
- **numer na opalitku**

#### Scenario: Dodanie matki reproduktorki
- **WHEN** użytkownik w rozwiniętej sekcji „Matki reproduktorki” wypełni numer ula, wybierze/poda rasę i linię (zgodnie z listą linii w ustawieniach, np. `car. Galicja`), wybierze kolor opalitka oraz wpisze numer na opalitku i zatwierdzi zapis
- **THEN** nowa matka reproduktorka zostaje dodana do listy w sekcji „Matki reproduktorki” oraz zapisana w danych użytkownika

#### Scenario: Edycja matki reproduktorki
- **WHEN** użytkownik wybierze akcję edycji przy istniejącej matce reproduktorce, zmodyfikuje dowolne pole (numer ula, rasa i linia, kolor opalitka, numer na opalitku) i zapisze zmiany
- **THEN** zaktualizowane dane matki reproduktorki są widoczne na liście oraz utrwalone

#### Scenario: Usunięcie matki reproduktorki
- **WHEN** użytkownik wybierze akcję usunięcia przy matce reproduktorce (i potwierdzi operację, jeśli wymagane)
- **THEN** wybrana matka reproduktorka zostaje usunięta z listy oraz z zapisanych danych użytkownika

---

### Requirement: Zarządzanie listami starterów i finisherów
W sekcjach **Startery** oraz **Finishery** użytkownik MUST móc przeglądać listy zasobów oraz dodawać, edytować i usuwać elementy. Każdy element w sekcji **Startery** oraz w sekcji **Finishery** MUST zawierać:
- **numer ula**

#### Scenario: Dodanie, edycja i usunięcie startera
- **WHEN** użytkownik w sekcji „Startery” doda pozycję z podanym numerem ula, następnie wyedytuje jej numer ula, a później ją usunie
- **THEN** lista starterów aktualizuje się po każdej z tych operacji i utrwala zmiany
- **AND** gdy lista starterów jest pusta, wyświetlany jest czytelny komunikat o braku zasobów

#### Scenario: Dodanie, edycja i usunięcie finishera
- **WHEN** użytkownik w sekcji „Finishery” doda pozycję z podanym numerem ula, następnie wyedytuje jej numer ula, a później ją usunie
- **THEN** lista finisherów aktualizuje się po każdej z tych operacji i utrwala zmiany
- **AND** gdy lista finisherów jest pusta, wyświetlany jest czytelny komunikat o braku zasobów

---

### Requirement: Spójna stylizacja w Tailwind CSS i wsparcie trybu ciemnego
Nagłówek widoku **Hodowla matek** oraz widok **Zarządzanie zasobami** MUST być ostylowane przy użyciu **Tailwind CSS** z zachowaniem spójności wizualnej z resztą aplikacji, czytelnego układu kartowego, wygodnych obszarów dotykowych oraz pełnego wsparcia dla trybu jasnego i ciemnego (`dark:`).

#### Scenario: Czytelność kart, formularzy i akcji w trybie jasnym i ciemnym
- **WHEN** użytkownik korzysta z widoku „Zarządzanie zasobami” w trybie jasnym lub ciemnym
- **THEN** każda z trzech zwijanych sekcji prezentowana jest jako czytelna karta z licznikiem pozycji, formularze dodawania/edycji są wizualnie oddzielone od listy rekordów, a przyciski „Edytuj” i „Usuń” są wyraźnie rozróżnione

---

## MODIFIED Requirements

### Requirement: Główny widok Hodowli matek
Główny widok **Hodowla matek** MUST służyć do zarządzania seriami matek (dodawanie, edycja oraz usuwanie serii), natomiast dodawanie, edycja i usuwanie zasobów (matki reproduktorki, startery, finishery) MUST być przeniesione do widoku **Zarządzanie zasobami**.

#### Scenario: Zarządzanie seriami matek na głównym widoku
- **WHEN** użytkownik przegląda główny widok **Hodowla matek**
- **THEN** widzi sekcję/listę serii matek z możliwością dodawania, edycji i usuwania poszczególnych serii
- **AND** formularze oraz listy zasobów (reproduktorek, starterów, finisherów) nie zaśmiecają głównego widoku hodowli matek
