# Hives

## Purpose
Manages commercial hives (ule towarowe) including structural korpusy configuration, queen and excluder tracking, and vertical layout display.

## Requirements

### Requirement: Commercial Hive Management
Users SHALL be able to create, edit, and view commercial hives with multi-korpus architecture.

#### Scenario: Korpus Editor Operations
- **WHEN** a user modifies a commercial hive's korpuses
- **THEN** they MUST be able to add a korpus above or below any existing korpus, toggle "krata odgrodowa" (excluder) and "matka" (queen) presence with explanatory tooltips `(i)`, and delete korpuses with a minimum safeguard of at least 1 korpus.

### Requirement: Hive Vertical Display
Commercial hives MUST be visually organized and displayed vertically.

#### Scenario: Sequential Line Layout
- **WHEN** multiple commercial hives exist in a commercial apiary
- **THEN** each successive hive MUST be displayed in a subsequent line underneath the previous one.

### Requirement: New Hive Types Support
The system SHALL support multiple commercial hive types including korpusowy, lezak, and kombinowany, with type-specific frame and super capacity limits and adjustment controls.

#### Scenario: Selecting Hive Types
- **WHEN** a user creates or edits a commercial hive
- **THEN** they MUST be able to select between korpusowy, lezak, and kombinowany, and configure type-specific parameters (brood nest, supers, frame counts).

#### Scenario: Lezak Hive Capacity and Frame Controls
- **WHEN** a user creates or configures a lezak hive
- **THEN** they MUST configure maximum brood frames (`maxBroodFrames`) and whether a super is present (`hasSuper`). If `hasSuper` is true, they MUST configure maximum super frames (`maxSuperFrames`).
- **AND** the active number of brood frames MUST be adjustable between 1 and `maxBroodFrames`.
- **AND** when `hasSuper` is true, the active number of super frames MUST be adjustable between 1 and `maxSuperFrames`.

#### Scenario: Kombinowany Hive Super Adjustment Buttons
- **WHEN** a user views or edits a kombinowany hive
- **THEN** they MUST be able to increase or decrease the number of supers using dedicated "Dodaj nadstawkę" and "Zabierz nadstawkę" buttons with a minimum limit of 0 supers.
