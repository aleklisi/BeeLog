# Design

## Context

The app is an Elm SPA with Firebase persistence in `frontend/src/index.js` behind Elm ports. User settings are stored on `users/{uid}`. Apiaries are stored in the top-level `pasieczyska` collection and already use `apiaryType` values `trutowisko` and `towarowe`. The current `ApiariesView` combines both types behind a filter, and settings already persist independent flags for those types. Elm unit tests live in `frontend/tests`; Playwright E2E tests live in `e2e/` and use an E2E local-storage state.

## Goals / Non-Goals

**Goals:**

- Fit the new routes and menu into the existing Elm model and navigation flow.
- Keep existing apiary records and user settings compatible.
- Store queen-rearing records per user and prevent resource conflicts during concurrent updates.
- Make acceptance scenarios independently testable with Elm unit tests and Playwright E2E tests.

**Non-Goals:**

- Changing the current data model or lifecycle of commercial hives and mating hives.
- Sharing queen-rearing resources between user accounts.
- Adding external notification delivery; urgency is shown in the application.

## Decisions

### Use separate route states with shared existing detail views

Add distinct primary route states for mating-apiary and commercial-apiary lists, plus queen-rearing views. Keep existing `UlikListView`, `HiveListView`, and their detail flows. Replace the combined apiary type filter with type-scoped list rendering and creation. The menu is a shared Elm view with explicit expanded state, accessible name, and `aria-expanded`; it closes after navigation. Settings and logout are fixed entries.

### Persist settings with backwards-compatible defaults

Add queen-rearing fields to the existing `UserSettings` type, decoder, Elm ports, and `users/{uid}` merge writes. Existing settings documents without the new fields keep current values for both apiary toggles and receive queen rearing disabled. Queen-rearing defaults are initialized from the approved defaults when absent. Each toggle updates only its own setting and any necessary navigation fallback.

### Store queen-rearing data under the user's Firestore document

Use `users/{uid}/breederQueens/{id}`, `users/{uid}/starterColonies/{id}`, `users/{uid}/finisherColonies/{id}`, and `users/{uid}/rearingBatches/{id}`. Store sequence documents under `users/{uid}/rearingSequences/{year}`. References are document IDs scoped to the same user, not relational foreign keys. Firestore rules must require the authenticated UID to match the parent user ID for these subcollections.

Keep colony availability (`PUSTY`/`ZAJETY`) and the active batch ID on colony records for efficient UI display, while treating batch assignment as the source of truth. Every batch transition that reserves or releases a colony updates the batch and affected colony records in one Firestore transaction. A transaction also allocates the yearly batch number, so concurrent creation cannot issue duplicate numbers. Deleting a batch uses the same transaction to release its colony; deleting a colony referenced by an active batch is rejected.

### Snapshot the schedule when a batch starts

When a planned batch starts, store the configured durations, the graft timestamp, and the IANA time-zone identifier with the batch. Store instants in Firestore timestamps (UTC); calculate calendar-day deadlines while preserving the local wall-clock time in the captured time zone. A future settings change affects batches that start afterward, not active batches. Editing the graft timestamp recalculates that batch from its saved durations.

### Keep business logic testable outside the views

Implement schedule calculations, count validation, transition eligibility, urgency classification, and batch sorting as pure functions where practical. Elm unit tests cover these functions. Use Playwright for the user-visible flows, Firestore/E2E persistence behavior, menu state, and complete batch transitions. Extend the existing E2E local-storage state with queen-rearing records and settings so tests remain isolated from production Firebase.

### Add one test per acceptance scenario at the right level

Queen-rearing calculation and validation scenarios map to Elm unit tests. Concurrency and persistence outcomes map to E2E or transaction-focused integration tests. Menu, apiary separation, toggle persistence, and complete user workflows map to Playwright. Existing scenarios in `e2e/beelog.spec.js` remain regression coverage for current apiary and hive behavior.

## Risks / Trade-offs

- **Firestore rules may not cover user subcollections today** → Add explicit owner-scoped rules and verify unauthenticated and cross-user access is denied.
- **Time-zone calculations can differ around daylight-saving transitions** → Persist the IANA zone and test a date range that crosses a clock change.
- **Concurrent transactions can fail and require retry or user feedback** → Surface a clear conflict message and leave all documents unchanged on a failed transition.
- **Legacy settings documents lack the queen-rearing fields** → Apply defaults in both the Elm decoder and JS load path, and test the legacy-document scenario.
- **Separating list routes can affect deep links and back navigation** → Preserve existing detail route payloads and add E2E coverage for opening and returning to both apiary types.

## Migration Plan

1. Extend settings with backwards-compatible defaults and update the settings UI.
2. Add explicit Firestore rules and E2E storage support for the per-user queen-rearing collections.
3. Implement pure queen-rearing logic and resource/batch persistence with transactional transitions.
4. Add the type-specific apiary routes and hamburger navigation while retaining existing detail views.
5. Add and run unit, E2E, and rules checks before release.

Rollback can disable the queen-rearing setting and restore the previous combined apiary route. Existing apiary records remain unchanged; newly created queen-rearing collections can remain unused without affecting existing features.
