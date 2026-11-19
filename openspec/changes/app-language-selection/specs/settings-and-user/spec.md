# Spec Delta

## ADDED Requirements

### Requirement: Language Selection Setting
The application SHALL support two UI languages — Polish (`pl`, default) and English (`en`) — selectable by the user in Settings.

#### Scenario: Default language on first load
- **GIVEN** a new user has never configured a language
- **WHEN** the application loads
- **THEN** Polish is used for all displayed strings

#### Scenario: Language selector is visible in Settings
- **GIVEN** a user is on the Settings screen
- **WHEN** the General section is displayed
- **THEN** a language selector control MUST be visible with options "Polski" and "English", and the current language MUST be pre-selected
- **AND** the selector MUST be rendered with `data-testid="language-select"`

#### Scenario: Switching to English
- **GIVEN** the application is in Polish
- **WHEN** the user selects "English" from the language selector
- **THEN** all visible UI strings switch to English immediately (without page reload)
- **AND** navigation items, button labels, section headings, placeholders, and tooltips are all displayed in English

#### Scenario: Switching back to Polish
- **GIVEN** the application is in English
- **WHEN** the user selects "Polski" from the language selector
- **THEN** all visible UI strings switch back to Polish immediately

#### Scenario: Language choice is persisted in Firestore
- **GIVEN** the user has selected English
- **WHEN** the user signs out and signs back in
- **THEN** the application loads in English

#### Scenario: Language choice is applied before Firestore responds
- **GIVEN** the user previously chose English
- **WHEN** the page is refreshed
- **THEN** the UI is in English from the moment the page renders (using `localStorage` key `beelog_language`)

#### Scenario: Legacy settings without a language field
- **GIVEN** a user's Firestore settings document does not contain a `language` field
- **WHEN** the application loads those settings
- **THEN** language defaults to Polish and all other settings are preserved unchanged

---

## MODIFIED Requirements

### Requirement: Sectioned Settings and Feature Toggles
Settings SHALL be organized into sections (General, Commercial Apiaries, Mating Apiaries, Queen Rearing) and all section headings, labels, button text, and tooltips SHALL be rendered in the currently selected language.

#### Scenario: Configuration and Sections
- **WHEN** a user accesses settings
- **THEN** options MUST be grouped into four sections (General, Commercial Apiaries, Mating Apiaries, Queen Rearing) with information tooltips `(i)`, optional feature toggles for commercial apiaries and mating apiaries, user email display, and parameters for hatching-to-mating days (1-30) and max history events (10-60).

#### Scenario: Settings screen in English
- **GIVEN** the language is set to English
- **WHEN** a user opens Settings
- **THEN** all section titles, field labels, button labels, placeholder text, and tooltip strings MUST appear in English

#### Scenario: Settings screen in Polish
- **GIVEN** the language is set to Polish
- **WHEN** a user opens Settings
- **THEN** all section titles, field labels, button labels, placeholder text, and tooltip strings MUST appear in Polish

---

## ADDED Requirements

### Requirement: Translated View Strings Across All Views
Every user-visible string in the application (headings, labels, buttons, placeholders, error/success messages, tooltips, navigation items, modal titles, table headers) SHALL be sourced from the `I18n` translation record and reflect the active language.

#### Scenario: Apiary list in English
- **GIVEN** the language is set to English
- **WHEN** the apiary list is displayed
- **THEN** "Twoje Pasieczyska" appears as "Your Apiaries", "Filtruj typ:" as "Filter by type:", "+ Dodaj Pasieczysko" as "+ Add Apiary", and so on for all labels in that view

#### Scenario: Hive detail in English
- **GIVEN** the language is set to English
- **WHEN** a hive detail screen is displayed
- **THEN** all field labels (queen, frame type, super, etc.), button text, and section headings appear in English

#### Scenario: No untranslated string remains in any view
- **GIVEN** the language is set to English
- **WHEN** any view is displayed
- **THEN** no Polish string is visible (every hard-coded Polish literal has been replaced with a translation key)

---

## ADDED Requirements

### Requirement: I18n Translation Module
A dedicated `I18n` Elm module SHALL define a `Translations` record type with a field for every user-visible string, and a `translationsFor : Language -> Translations` function that returns the correct record for each supported language.

#### Scenario: All keys present in both languages
- **GIVEN** the `Translations` record type
- **WHEN** `translationsFor PL` and `translationsFor EN` are called
- **THEN** every field in the record is a non-empty string in both results

#### Scenario: Translations record is the single source of truth
- **GIVEN** the `I18n` module exists
- **WHEN** any view module renders a user-visible string
- **THEN** it uses `t.someKey` from the passed-in `Translations` value and does NOT contain any hard-coded Polish or English string literals (except proper nouns, brand names like "BeeLog", and technical identifiers)
