# Spec Delta

## ADDED Requirements

### Requirement: Identify mating hives requiring attention
The mating-apiary hive list SHALL show a red exclamation mark on the right side of each hive row when that hive requires attention, and the mark SHALL reveal the reason on hover or keyboard focus.

#### Scenario: Hive without a queen requires attention
- **GIVEN** a hive is in the Bezmatek state
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a red exclamation mark whose explanation says that the hive has no queen

#### Scenario: Overdue expected emergence requires attention
- **GIVEN** a hive is in the Matecznik state and its expected emergence date is before today's date
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a red exclamation mark whose explanation asks the user to check whether the queen emerged

#### Scenario: Overdue expected mating requires attention
- **GIVEN** a hive is in the Matka wygryziona state and its expected mating date is before today's date
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a red exclamation mark whose explanation says the expected mating date has passed

#### Scenario: Hive without an overdue condition has no attention mark
- **GIVEN** a hive is not in the Bezmatek state and any applicable expected date is today or later
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row does not show an attention mark
