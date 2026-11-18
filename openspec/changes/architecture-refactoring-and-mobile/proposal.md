# Proposal: Architecture Refactoring and Mobile Responsiveness

## Why
To maintain codebase maintainability and ensure the application works seamlessly on small mobile screens (smartphones in the apiary).

## What Changes
- Split `Types.elm` into smaller modular files.
- Extract single commercial hive and mating hive views into separate files from apiary views.
- Adapt layout and UI views for small mobile screens (responsive design, touch-friendly elements, no horizontal scroll).

## Capabilities

### Modified Capabilities
- `hives`: Component extraction and mobile layout.
- `mating-apiaries`: Component extraction and mobile layout.
- `testing-and-ci`: Responsive UI testing.

## Impact
Elm source code organization and CSS/responsive styling.
