# Spec Delta

## Purpose

Separates mating apiaries and commercial apiaries into distinct primary views while preserving their existing data and type-specific operations.

## ADDED Requirements

### Requirement: Show apiaries in separate type-specific views
The application SHALL provide separate Mating Apiaries and Commercial Apiaries views. Each view SHALL show only apiaries of its type and SHALL provide access to each apiary's existing details.

#### Scenario: View mating apiaries
- **GIVEN** the user has mating and commercial apiaries
- **WHEN** the user opens Mating Apiaries
- **THEN** only apiaries with type `trutowisko` are shown

#### Scenario: View commercial apiaries
- **GIVEN** the user has mating and commercial apiaries
- **WHEN** the user opens Commercial Apiaries
- **THEN** only apiaries with type `towarowe` are shown

#### Scenario: Show an empty type-specific view
- **GIVEN** the user has no apiaries of the selected type
- **WHEN** the user opens that type's view
- **THEN** the view shows an empty state and offers creation of an apiary of that type

### Requirement: Create an apiary from its type-specific view
Creating an apiary from a type-specific view SHALL assign that view's apiary type and SHALL NOT offer a conflicting type selection.

#### Scenario: Create a mating apiary
- **WHEN** the user creates an apiary from Mating Apiaries
- **THEN** the new apiary has type `trutowisko`

#### Scenario: Create a commercial apiary
- **WHEN** the user creates an apiary from Commercial Apiaries
- **THEN** the new apiary has type `towarowe`

### Requirement: Preserve apiary data when its view is disabled
Disabling an apiary type SHALL hide its primary view and its menu entry without deleting or modifying apiaries or their contents.

#### Scenario: Disable one apiary view
- **GIVEN** both apiary types are enabled and have saved data
- **WHEN** the user disables Mating Apiaries
- **THEN** Mating Apiaries is hidden, Commercial Apiaries remains available, and all mating-apiary data is preserved
