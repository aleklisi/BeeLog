# Spec Delta

## ADDED Requirements

### Requirement: Pasieczyska use semantic colors for create, rename, delete, and navigation actions
Actions for creating or renaming an apiary and navigating from an apiary view MUST use a high-contrast dark-green treatment in light and dark themes. Deletion actions MUST use a high-contrast red treatment in both themes.

#### Scenario: Apiary actions are distinguishable in either theme
- **WHEN** a user views apiary lists or an apiary's commercial-hive list in light or dark theme
- **THEN** create, rename, and back/navigation actions appear dark green, while delete actions appear red, with readable text and visible hover and keyboard-focus states
