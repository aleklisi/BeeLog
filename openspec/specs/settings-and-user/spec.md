# Settings and User

## Purpose
Manages application settings grouped into sections, user profile data, and optional feature flags.

## Requirements

### Requirement: Sectioned Settings and Feature Toggles
Settings SHALL be organized logically into sections with configurable parameters and optional feature toggles.

#### Scenario: Configuration and Sections
- **WHEN** a user accesses settings
- **THEN** options MUST be grouped into three sections (Ogólne, Pasieczyska towarowe, Trutowiska) with information tooltips `(i)`, optional feature toggles for commercial apiaries and mating apiaries, user email display, and parameters for hatching-to-mating days (1-30) and max history events (10-60).
