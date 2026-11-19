# Spec Delta

## ADDED Requirements

### Requirement: Mating-hive list can show only hives requiring action
The mating-apiary hive list SHALL provide an unchecked `Tylko wymagające akcji` checkbox that filters the visible hives by the existing attention rules when selected.

#### Scenario: Default list shows all hives
- **WHEN** the user opens a mating-apiary hive list
- **THEN** the checkbox is unchecked and the list shows the same hives as the current view, subject only to any existing state filter

#### Scenario: Action-only filter is enabled
- **WHEN** the user checks `Tylko wymagające akcji`
- **THEN** the list shows only hives whose current state or dates require action according to the existing attention rules
- **AND** hives that do not require action are hidden

#### Scenario: Due today is included
- **GIVEN** a hive has an applicable expected hatching or mating date equal to the current date
- **WHEN** the action-only filter is checked
- **THEN** that hive is shown as requiring action

#### Scenario: Overdue hives are included
- **GIVEN** a hive has an applicable expected hatching or mating date before the current date
- **WHEN** the action-only filter is checked
- **THEN** that hive is shown as requiring action

#### Scenario: Queenless hive is included
- **GIVEN** a hive is in the `Bezmatek` state
- **WHEN** the action-only filter is checked
- **THEN** that hive is shown as requiring action regardless of missing dates

#### Scenario: Action-only filter combines with state filter
- **GIVEN** the user has selected both an action-only filter and a specific hive state
- **WHEN** the list is rendered
- **THEN** only hives matching both conditions are shown

#### Scenario: Turning the filter off restores the list
- **WHEN** the user unchecks `Tylko wymagające akcji`
- **THEN** the list again shows all hives allowed by the selected state filter, including hives with future dates
