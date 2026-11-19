# Spec Delta

## Purpose

Provides drag-and-drop ordering for mating-hive cards in a mating-apiary list without changing mating-hive lifecycle data or filtering behavior.

## ADDED Requirements

### Requirement: Reorder mating hives by drag and drop

The mating-hive list view SHALL allow a user to drag a mating-hive card to a different position in the list.

#### Scenario: Move a mating hive to a new position

- **WHEN** the user drags mating hive A and drops it before or after mating hive B
- **THEN** hive A SHALL be rendered at the selected position relative to hive B
- **AND** the up/down reorder arrow controls SHALL not be displayed

#### Scenario: Preserve mating-hive data while reordering

- **WHEN** the user reorders a mating hive
- **THEN** its name, state, timeline dates, queen data, history, and other details SHALL remain associated with that hive

### Requirement: Persist mating-hive order within the mating apiary

The application SHALL save mating-hive order for the owning mating apiary and SHALL retain the order independently for each mating apiary.

#### Scenario: Order survives navigation and reload

- **WHEN** the user reorders mating hives and then leaves and returns to the mating-hive list or reloads the application
- **THEN** the mating hives SHALL appear in the saved order
- **AND** mating hives in another mating apiary SHALL not be reordered

#### Scenario: Reordering with a state filter

- **WHEN** the user reorders the currently visible mating-hive cards while a state filter is active
- **THEN** the visible cards SHALL follow the selected drop position
- **AND** mating hives hidden by the filter SHALL retain their relative order and data

### Requirement: Keep mating-hive actions separate from dragging

Dragging a mating-hive card SHALL not navigate to its details or open rename, move, or delete controls.

#### Scenario: Complete a mating-hive drag

- **WHEN** the user drops a mating-hive card at a valid position
- **THEN** only the list order SHALL be updated
- **AND** the user SHALL remain on the mating-hive list view
