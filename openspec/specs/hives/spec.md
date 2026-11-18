# Hives

## Purpose
Manages commercial hives (ule towarowe) including structural korpusy configuration, queen and excluder tracking, and vertical layout display.

## Requirements

### Requirement: Commercial Hive Management
Users SHALL be able to create, edit, and view commercial hives with multi-korpus architecture.

#### Scenario: Korpus Editor Operations
- **WHEN** a user modifies a commercial hive's korpuses
- **THEN** they MUST be able to add a korpus above or below any existing korpus, toggle "krata odgrodowa" (excluder) and "matka" (queen) presence with explanatory tooltips `(i)`, and delete korpuses with a minimum safeguard of at least 1 korpus.

### Requirement: Hive Vertical Display
Commercial hives MUST be visually organized and displayed vertically.

#### Scenario: Sequential Line Layout
- **WHEN** multiple commercial hives exist in a commercial apiary
- **THEN** each successive hive MUST be displayed in a subsequent line underneath the previous one.
