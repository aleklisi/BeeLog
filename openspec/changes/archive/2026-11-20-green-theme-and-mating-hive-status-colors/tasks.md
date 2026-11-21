# Tasks

## 1. Shared green interface palette

- [x] 1.1 Define consistent light/dark utility patterns for primary and secondary buttons, form controls, badges, and surfaces in the affected views, including visible hover and focus states.
- [x] 1.2 Style destructive actions red with readable light/dark text across list and confirmation actions while preserving their existing behavior.

## 2. Mating hive status colors

- [x] 2.1 Add a shared mapping from B, M, N, and UNC statuses to the existing timeline color families and apply it to status labels/actions in mating hive views.
- [x] 2.2 Mark the current status visually and with `aria-pressed` where controls represent selectable status, while keeping transition actions and labels accessible.

## 3. Verification

- [x] 3.1 Add or update Elm tests for status-to-color/active-state rendering where existing test structure supports it; run `make elm_test` and `make test_openspec`.
- [x] 3.2 Review affected views in light and dark themes and confirm utility classes are included in the built stylesheet.
