# Spec Delta

## ADDED Requirements

### Requirement: Mating apiary indicates hives requiring immediate attention
The mating-apiary card SHALL show a red exclamation mark when at least one mating hive in that apiary has an active attention condition, and the mark SHALL expose the names of all such hives on hover or keyboard focus.

#### Scenario: Apiary with one attention-required hive
- **GIVEN** a mating apiary contains a hive whose existing attention rules require action
- **WHEN** the user views the apiary list
- **THEN** the apiary card shows one red exclamation mark and its tooltip and accessible label contain the name of that hive

#### Scenario: Apiary with multiple attention-required hives
- **GIVEN** a mating apiary contains multiple hives whose existing attention rules require action
- **WHEN** the user hovers over or focuses the apiary alert
- **THEN** the tooltip and accessible label contain every affected hive name in the apiary's current hive-list order

#### Scenario: Apiary without attention-required hives
- **GIVEN** no hive in a mating apiary has an active attention condition
- **WHEN** the user views the apiary list
- **THEN** the apiary card does not show the red exclamation mark

#### Scenario: Alert is available by keyboard
- **GIVEN** a mating apiary has at least one attention-required hive
- **WHEN** the user moves keyboard focus to the apiary alert
- **THEN** the same affected-hive name list is available through the alert's accessible name and native tooltip without opening the apiary

#### Scenario: Commercial apiaries are unaffected
- **GIVEN** a commercial apiary is shown on the apiary list
- **WHEN** the user views the commercial apiary card
- **THEN** the card does not show a mating-hive attention alert
