# Settings and User

## Purpose
Manages application settings grouped into sections, user profile data, and optional feature flags.

## Requirements

### Requirement: Sectioned Settings and Feature Toggles
Settings SHALL be organized logically into sections with configurable parameters and optional feature toggles.

#### Scenario: Configuration and Sections
- **WHEN** a user accesses settings
- **THEN** options MUST be grouped into four sections (Ogólne, Pasieczyska towarowe, Trutowiska, Queen Rearing) with information tooltips `(i)`, optional feature toggles for commercial apiaries and mating apiaries, user email display, and parameters for hatching-to-mating days (1-30) and max history events (10-60).

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
