# Spec Delta

## MODIFIED Requirements

### Requirement: Moving Mating Hives
Users SHALL be able to relocate mating hives between mating apiaries.

#### Scenario: Relocation and Back Navigation
- **WHEN** a mating hive is moved from Mating Apiary A to Mating Apiary B
- **THEN** it MUST be reassigned to Apiary B and the back button navigation MUST correctly return to the current apiary view.

#### Scenario: Back Navigation from an Existing NFC Link
- **WHEN** a user opens a mating hive through its existing NFC link after it has been moved to another apiary
- **THEN** the detail view MUST use the apiary where the hive currently resides, and the back button MUST return to that apiary.
