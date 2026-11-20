# Hives

## Purpose
Manages commercial hives (ule towarowe) including structural korpusy configuration, queen and excluder tracking, and vertical layout display.

## Requirements

### Requirement: Voice Dictation for Commercial Hive Notes
Users SHALL be able to dictate notes for commercial hives using the browser's supported speech recognition interface.

#### Scenario: Dictated text is added to a commercial hive note
- **WHEN** a user starts voice dictation while viewing a commercial hive and speech is recognized
- **THEN** the recognized text MUST be added to the note being composed.

### Requirement: Commercial Hive Management
Users SHALL be able to create, edit, and view commercial hives with multi-korpus architecture.

#### Scenario: Korpus Editor Operations
- **WHEN** a user modifies a commercial hive's korpuses
- **THEN** they MUST be able to add a korpus immediately above or below the selected existing korpus, toggle "krata odgrodowa" (excluder) and "matka" (queen) presence with explanatory tooltips `(i)`, and delete the selected korpus with a minimum safeguard of at least 1 korpus.

#### Scenario: Korpus Operations Keep the Selected Target
- **WHEN** a user adds a korpus above or below a specific korpus
- **THEN** the new korpus MUST appear on the selected side of that korpus, regardless of its position in the hive.
- **WHEN** a user deletes a korpus
- **THEN** the korpus identified by that delete control MUST be removed, and other korpuses MUST retain their data.
- **AND** at least one korpus MUST remain.

#### Scenario: Reorder Korpuses by Drag and Drop
- **WHEN** a user drags a korpus to another position in a korpusowy hive
- **THEN** the korpus MUST move before or after the korpus at the selected drop zone and the order MUST be saved.
- **AND** its queen and excluder data MUST remain associated with that korpus.
- **AND** its displayed korpus number MUST remain stable when its position changes.

#### Requirement: Korpus Barrier and Entrance State
Each korpus in a korpusowy hive SHALL independently track an excluder above it, a sealed foil above it, and whether its entrance is open.

#### Scenario: Configure Foil Above a Korpus
- **WHEN** a user toggles "Folia na korpusie" for a korpus
- **THEN** the state MUST be saved independently for that korpus and shown as a barrier above it, like the excluder marker.
- **AND** an information hint MUST explain that the sealed foil separates korpuses above it from those below it.

#### Scenario: Configure an Open Entrance
- **WHEN** a user toggles "Otwarty wylotek w korpusie" for a korpus
- **THEN** the open entrance state MUST be saved independently for that korpus and support managing a two-queen hive.

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

#### Scenario: Non-negative Initial Super Count
- **WHEN** a user creates a kombinowany hive
- **THEN** the initial number of supers MUST be 0 or greater, and negative values MUST NOT be saved.

#### Scenario: Hive Snapshot Content
- **WHEN** a user saves a hive snapshot as a note
- **THEN** the snapshot MUST include the hive name, hive type, pollen trap, and queen information, and MUST NOT include an NFC link.
- **AND** a leżak snapshot MUST include brood frame type and count, whether a super is present, and super frame type and active and maximum frame counts when present.
- **AND** a kombinowany snapshot MUST include brood frame type and count and the number and frame type of supers.
- **AND** a korpusowy snapshot MUST include its frame type.
- **AND** a korpusowy snapshot MUST list korpuses from top to bottom with each korpus's queen, excluder, foil, and open entrance states.
