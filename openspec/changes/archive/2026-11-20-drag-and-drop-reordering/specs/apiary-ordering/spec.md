# Spec Delta

## Purpose

Provides a direct, persistent way to arrange apiary cards in the type-specific apiary views, while keeping apiary actions and data unchanged.

## ADDED Requirements

### Requirement: Reorder apiaries by drag and drop

The application SHALL allow a user to drag an apiary card to a different position in the currently displayed apiary list.

#### Scenario: Move an apiary before another apiary

- **WHEN** the user drags apiary A and drops it before apiary B
- **THEN** apiary A SHALL be displayed immediately before apiary B
- **AND** the up/down or left/right reorder arrow controls SHALL not be displayed

#### Scenario: Move an apiary after another apiary

- **WHEN** the user drags apiary A and drops it after apiary B
- **THEN** apiary A SHALL be displayed immediately after apiary B

### Requirement: Persist apiary order

The application SHALL save the new apiary order and use it for subsequent displays of the same apiary list.

#### Scenario: Order survives navigation and reload

- **WHEN** the user reorders apiaries and then leaves and returns to the list or reloads the application
- **THEN** the apiaries SHALL appear in the saved order
- **AND** each apiary's name, type, contents, and existing actions SHALL remain unchanged

### Requirement: Keep drag operations separate from card actions

Dragging an apiary card SHALL not activate the card's navigation, edit, delete, or other action controls.

#### Scenario: Drop an apiary without opening it

- **WHEN** the user completes a drag-and-drop operation on an apiary card
- **THEN** only the order SHALL change
- **AND** the application SHALL not navigate to the apiary or open an action modal
