# Tasks

## 1. User settings and main navigation

- [ ] 1.1 Extend Elm settings types, decoders, ports, and Firestore merge reads/writes with queen-rearing defaults and an independent disabled-by-default feature flag; verify legacy settings decoding with Elm tests.
- [ ] 1.2 Add the queen-rearing settings controls and hamburger menu with accessible expanded state, keyboard operation, enabled-view entries, and fixed Settings/Logout entries; verify menu and settings behavior with Playwright.
- [ ] 1.3 Add Playwright coverage for independent toggle persistence across reload/sign-in, menu visibility, logout, and fallback when disabling the current view; verify all relevant scenarios pass.

## 2. Separate apiary views

- [ ] 2.1 Add independent mating-apiary and commercial-apiary routes and remove the combined type filter from primary navigation; verify each route renders only its apiary type with Playwright.
- [ ] 2.2 Bind apiary creation to the current view's type and preserve existing apiary detail routes; verify type assignment, empty states, and open/back navigation in Playwright.
- [ ] 2.3 Add Playwright regression coverage proving that disabling one apiary view hides it without deleting data or changing the other view, and rerun existing apiary/hive E2E scenarios.

## 3. Queen-rearing data and domain rules

- [ ] 3.1 Add Elm domain types, decoders, encoders, validation, schedule calculation, urgency classification, and batch sorting; verify defaults, bounds, transition eligibility, time-zone dates, and ordering with Elm unit tests.
- [ ] 3.2 Add user-scoped Firestore collections and owner-only rules for breeder queens, starters, finishers, batches, and yearly sequence documents; verify authorized and cross-user access behavior with rules or emulator tests.
- [ ] 3.3 Implement atomic batch-number allocation and transactional colony reservation/release, including rejection of concurrent conflicts and zero-acceptance completion; verify no partial writes with transaction-focused tests.
- [ ] 3.4 Extend the E2E persistence adapter for queen-rearing records and settings; verify create/read/update/delete behavior and legacy settings defaults with Playwright.

## 4. Queen-rearing workflows and views

- [ ] 4.1 Add resource management views for breeder queens, starters, and finishers, including unavailable-resource indicators and deletion safeguards; verify CRUD and active-resource protection with Playwright.
- [ ] 4.2 Add planned-batch creation and state-specific transition forms with validation, resource selection, schedule details, and incubator/direct completion; verify full-cycle, invalid-count, zero-acceptance, and direct-completion flows with Playwright.
- [ ] 4.3 Add the batch list, timeline, next-action alerts, and priority sorting; verify overdue, within-24-hour, future, planned, and completed ordering scenarios with Playwright.

## 5. Integration verification

- [ ] 5.1 Run `npm run test:elm` and `npm run test:e2e`; verify the new tests and existing regression suite pass.
- [ ] 5.2 Run `npm run build`; verify the application compiles with the new routes, settings, and queen-rearing views.
