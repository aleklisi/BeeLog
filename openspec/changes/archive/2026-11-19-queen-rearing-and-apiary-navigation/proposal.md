# Proposal

## Why

BeeLog needs an operational workflow for planning and tracking queen-rearing batches, including exclusive use of starter and finisher colonies. The current home view combines commercial and mating apiaries behind a filter and exposes navigation as header buttons; users need separate, settings-controlled views in a compact main menu.

## What Changes

- Add a queen-rearing capability for breeder queens, starter and finisher colonies, batch lifecycle, schedule calculation, resource availability, alerts, and batch history data.
- Add a hamburger main-navigation menu with separate entries for queen rearing, mating apiaries, commercial apiaries, settings, and logout. Optional entries follow per-user settings; settings and logout remain available.
- Split the combined apiary list into independent mating-apiary and commercial-apiary views. Creating a new apiary from either view assigns the corresponding existing apiary type.
- Add a per-user setting to enable or disable queen rearing. Preserve existing independent settings for mating and commercial apiaries and retain their data when a view is disabled.
- Add Elm unit tests for domain calculations and validations, and Playwright E2E tests for navigation, settings persistence, apiary view separation, and queen-rearing workflows.

## Capabilities

### New Capabilities

- `queen-rearing`: Queen-rearing resources, batches, lifecycle, schedule, alerts, and operational UI.
- `main-navigation`: Main menu, settings-controlled view visibility, and navigation behavior.
- `apiary-views`: Separate mating-apiary and commercial-apiary list views with type-correct creation and content.

### Modified Capabilities

- `settings-and-user`: Add a persisted per-user queen-rearing toggle and define independent feature visibility for the main menu.
- `testing-and-ci`: Require automated unit and E2E coverage for new capabilities and their acceptance scenarios.

## Impact

- Elm view state and routing in `frontend/src/Main.elm` and `frontend/src/Types/Core.elm`.
- Existing list and settings UI in `frontend/src/Views/ApiaryList.elm` and `frontend/src/Views/Settings.elm`.
- New queen-rearing Elm types, views, validation, and schedule logic.
- Firebase persistence and per-user settings in `frontend/src/index.js` and related Elm ports/decoders.
- Elm unit tests in `frontend/tests/ApiaryTest.elm` or focused new test modules, and Playwright scenarios in `e2e/`.
- Existing route and data compatibility for `apiaryType` values `trutowisko` and `towarowe`.
