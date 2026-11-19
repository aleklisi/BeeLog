# Proposal

## Why

Settings use inconsistent controls for numeric values and optional modules: queen-rearing options have a different layout from other settings, and module toggles use different presentations across sections. A shared styling foundation and consistent controls will make settings easier to scan and operate across the application.

## What Changes

- Add Tailwind CSS to the frontend build and establish reusable styling conventions for application controls.
- Standardize numeric inputs across settings so equivalent values use the same dimensions, spacing, alignment, and dark-mode treatment, including queen-rearing schedule values and hatching-to-mating days.
- Present optional-module toggles in a consistent single-row layout matching the current queen-rearing toggle treatment across all settings sections.
- Preserve current setting labels, ranges, persistence, language behavior, and section collapse behavior.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `settings-and-user`: Define consistent presentation for numeric setting fields and optional-module toggles across sections.

## Impact

- Frontend styling/build setup (`package.json`, Vite configuration, CSS entry point, and Elm view markup/classes).
- Settings view, with possible reuse of shared control styling elsewhere in the frontend.
- No data model, API, or persistence changes are expected.
