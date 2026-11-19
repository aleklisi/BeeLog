# Spec Delta

## MODIFIED Requirements

### Requirement: Sectioned Settings and Feature Toggles
Settings SHALL be organized into four sections (General, Commercial Apiaries, Mating Apiaries, and Queen Rearing) with information tooltips, user email display, existing configuration options, independent optional feature toggles, and queen-rearing defaults for graft count and schedule durations.

#### Scenario: Configuration and Sections
- **WHEN** a user accesses settings
- **THEN** options MUST be grouped into General, Commercial Apiaries, Mating Apiaries, and Queen Rearing sections with information tooltips, independent feature toggles, user email display, the existing parameters for hatching-to-mating days (1-30) and max history events (10-60), and queen-rearing defaults for graft count, starter duration (1-10 days), isolation day, and emergence day

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
