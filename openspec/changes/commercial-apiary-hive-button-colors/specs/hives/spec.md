# Spec Delta

## ADDED Requirements

### Requirement: Commercial hive primary actions use dark green
Create, rename, save, and navigation actions in commercial hive views MUST use a high-contrast dark-green treatment in light and dark themes.

#### Scenario: Primary hive actions are visible in both themes
- **WHEN** a user creates, renames, saves, or navigates from a commercial hive view in either theme
- **THEN** the relevant action appears dark green with readable text and visible hover and keyboard-focus states

### Requirement: Commercial hive destructive and cancel actions use red
Delete and cancel actions in commercial hive views MUST use a high-contrast red treatment in light and dark themes.

#### Scenario: Cancel or delete a hive change
- **WHEN** a user is offered a delete or cancel action while managing a commercial hive in either theme
- **THEN** the action appears red and remains distinguishable with readable text and visible hover and keyboard-focus states

### Requirement: Commercial hive voice dictation uses warm brown
Actions that start or control voice dictation for commercial hive notes MUST use a warm brown treatment with readable contrast in light and dark themes.

#### Scenario: Start voice dictation
- **WHEN** a user views the voice dictation action for a commercial hive note in either theme
- **THEN** the action appears warm brown with readable text and visible hover and keyboard-focus states
