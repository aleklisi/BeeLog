# Spec: Filtry i wyszukiwanie serii hodowlanych

## ADDED Requirements

### Requirement: Wyszukiwanie serii hodowlanych
Lista serii SHALL umożliwiać wyszukiwanie po numerze serii oraz numerze ula przypisanej matki reproduktorki. Wyszukiwanie SHALL ignorować wielkość liter i aktualizować widoczne wyniki bez modyfikowania danych.

#### Scenario: Znalezienie serii po numerze
- **GIVEN** użytkownik ma serie o różnych numerach
- **WHEN** wpisze fragment numeru serii
- **THEN** widoczne są serie, których numer zawiera wpisany tekst

#### Scenario: Znalezienie serii po ulu reproduktorki
- **GIVEN** seria ma przypisaną matkę reproduktorkę z numerem ula
- **WHEN** użytkownik wpisze ten numer ula
- **THEN** seria jest widoczna w wynikach

### Requirement: Filtrowanie listy według statusu
Lista serii SHALL oferować filtr z każdą wartością statusu dostępną w cyklu życia serii oraz domyślną opcją obejmującą wszystkie statusy. Filtr statusu i wyszukiwanie SHALL działać jednocześnie, a wyniki SHALL zachowywać istniejące sortowanie pilności.

#### Scenario: Połączenie filtra i wyszukiwania
- **GIVEN** wybrany status i wpisany tekst wyszukiwania
- **WHEN** lista jest wyświetlana
- **THEN** widoczne są wyłącznie serie o wybranym statusie pasujące do wyszukiwania, w kolejności pilności

#### Scenario: Brak wyników wyszukiwania
- **GIVEN** istnieją serie, ale żadna nie pasuje do kryteriów
- **WHEN** użytkownik wyświetla listę
- **THEN** aplikacja informuje o braku wyników i udostępnia reset filtrów

#### Scenario: Brak serii i brak wyników filtra
- **GIVEN** lista nie zawiera żadnych serii albo zawiera serie, lecz żadna nie pasuje do aktywnych kryteriów
- **WHEN** użytkownik wyświetla listę
- **THEN** aplikacja rozróżnia pustą listę serii od braku wyników filtrowania i dla braku wyników udostępnia reset filtrów

#### Scenario: Reset filtrów
- **WHEN** użytkownik wybierze reset
- **THEN** tekst wyszukiwania jest pusty, status obejmuje wszystkie serie i lista pokazuje wszystkie serie w kolejności pilności
