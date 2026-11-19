# Spec Delta

## Purpose

Provides drag-and-drop ordering for commercial hive cards within a commercial apiary, with the order retained independently for each apiary.

## ADDED Requirements

### Requirement: Reorder commercial hives by drag and drop

The commercial-apiary view SHALL allow a user to drag a commercial hive card to a different position in that apiary's hive list.

#### Scenario: Move a commercial hive to a new position

- **WHEN** the user drags commercial hive A and drops it before or after commercial hive B
- **THEN** hive A SHALL be rendered at the selected position relative to hive B
- **AND** the up/down reorder arrow controls SHALL not be displayed

#### Scenario: Preserve hive data while reordering

- **WHEN** the user reorders a commercial hive
- **THEN** the hive's name, type, frame configuration, queen data, and other details SHALL remain associated with that hive

### Requirement: Persist commercial hive order per apiary

The application SHALL save commercial hive order as part of the owning commercial apiary's data.

#### Scenario: Order survives leaving and reopening the apiary

- **WHEN** the user reorders commercial hives and leaves and reopens the commercial apiary
- **THEN** the hives SHALL appear in the saved order
- **AND** hives in another apiary SHALL not be reordered

### Requirement: Keep hive actions separate from dragging

Dragging a commercial hive card SHALL not open the hive details, rename dialog, or delete dialog.

#### Scenario: Complete a hive drag

- **WHEN** the user drops a commercial hive card at a valid position
- **THEN** only the hive order SHALL be updated
- **AND** the user SHALL remain on the commercial-apiary view
