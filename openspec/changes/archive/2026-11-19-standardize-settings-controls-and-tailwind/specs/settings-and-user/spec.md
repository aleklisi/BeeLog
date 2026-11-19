# Spec Delta

## ADDED Requirements

### Requirement: Consistent Numeric Settings Controls
Numeric settings across all settings sections SHALL use a consistent visual treatment, including equivalent sizing, spacing, alignment, and readable contrast in light and dark modes.

#### Scenario: Compare schedule values across sections
- **WHEN** a user views numeric settings for hatching-to-mating days and queen-rearing schedule values
- **THEN** the numeric inputs use the same visual dimensions and control styling while retaining their existing labels and validation ranges

#### Scenario: View numeric settings in dark mode
- **GIVEN** dark mode is enabled
- **WHEN** a user views a numeric settings control
- **THEN** its text, background, border, and focus state remain legible against the surrounding interface

### Requirement: Consistent Optional Module Toggles
Optional module toggles in Settings SHALL use the same single-row layout and control presentation across all sections.

#### Scenario: Compare module toggles across sections
- **WHEN** a user views the commercial apiaries, mating apiaries, and queen-rearing settings
- **THEN** each module toggle and its label appear together in a consistent single-row layout

#### Scenario: Toggle a module without affecting other settings
- **WHEN** a user changes one module toggle
- **THEN** only that module's setting changes and its existing persistence behavior is preserved
