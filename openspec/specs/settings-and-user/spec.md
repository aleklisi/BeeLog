# Settings and User

## Purpose
Manages application settings grouped into sections, user profile data, and optional feature flags.

## Requirements

### Requirement: Sectioned Settings and Feature Toggles
Settings SHALL be organized into four sections (General, Commercial Apiaries, Mating Apiaries, and Queen Rearing) with information tooltips, user email display, existing configuration options, independent optional feature toggles, and queen-rearing defaults for graft count and schedule durations. All section headings, labels, button text, and tooltips SHALL be rendered in the currently selected language.

#### Scenario: Configuration and Sections
- **WHEN** a user accesses settings
- **THEN** options MUST be grouped into four sections (General, Commercial Apiaries, Mating Apiaries, Queen Rearing) with information tooltips, independent optional feature toggles, user email display, the existing parameters for hatching-to-mating days (1-30) and max history events (10-60), and queen-rearing defaults for graft count, starter duration (1-10 days), isolation day, and emergence day.

#### Scenario: Persist queen-rearing visibility
- **GIVEN** queen rearing is available
- **WHEN** a user enables or disables its setting and signs in again
- **THEN** the selected value is restored for that user and does not change the mating-apiary or commercial-apiary settings

#### Scenario: Load settings created before the queen-rearing option
- **GIVEN** a user has saved settings that do not contain a queen-rearing value
- **WHEN** the application loads those settings
- **THEN** queen rearing defaults to disabled and the existing settings are preserved

#### Scenario: Disable a module without deleting its data
- **GIVEN** an optional module has saved user data
- **WHEN** the user disables that module
- **THEN** the module is hidden from primary navigation and its saved data remains available if the module is re-enabled

#### Scenario: Settings screen in English
- **GIVEN** the language is set to English
- **WHEN** a user opens Settings
- **THEN** all section titles, field labels, button labels, placeholder text, and tooltip strings MUST appear in English

#### Scenario: Settings screen in Polish
- **GIVEN** the language is set to Polish
- **WHEN** a user opens Settings
- **THEN** all section titles, field labels, button labels, placeholder text, and tooltip strings MUST appear in Polish

### Requirement: Collapsible Settings Sections
Each settings section SHALL be independently collapsible and expandable by the user.

#### Scenario: Default State — All Sections Expanded
- **WHEN** a user opens the Settings screen
- **THEN** all four sections MUST be expanded and their content MUST be visible.

#### Scenario: Collapsing a Section
- **WHEN** a user clicks the toggle button (∧) of an expanded section
- **THEN** that section's content MUST be hidden and the button icon MUST change to ∨.

#### Scenario: Expanding a Collapsed Section
- **WHEN** a user clicks the toggle button (∨) of a collapsed section
- **THEN** that section's content MUST become visible and the button icon MUST change to ∧.

#### Scenario: Section Header Accessibility
- **WHEN** a section header button is rendered
- **THEN** it MUST carry an `aria-expanded` attribute set to `"true"` when expanded and `"false"` when collapsed.

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

### Requirement: Translated View Strings Across All Views
Every user-visible string in the application (headings, labels, buttons, placeholders, error/success messages, tooltips, navigation items, modal titles, table headers) SHALL reflect the active language.

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

### Requirement: I18n Translation Module
The application SHALL provide complete Polish and English translations for every user-visible string, and render each string in the active language.

#### Scenario: All keys present in both languages
- **GIVEN** the application's translations
- **WHEN** either supported language is active
- **THEN** every user-visible string has a non-empty translation in that language

#### Scenario: Translations are consistently applied
- **GIVEN** the application is displaying user-visible text
- **WHEN** a view renders a string
- **THEN** it uses the translation for the active language, except for proper nouns, brand names like "BeeLog", and technical identifiers
