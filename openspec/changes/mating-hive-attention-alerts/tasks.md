# Tasks

## 1. Alert rules

- [ ] 1.1 Add a pure attention-reason helper for the three specified states using parsed expected dates and `Model.currentDate`; verify with Elm tests for Bezmatek, each overdue state, due-today/future dates, and missing or invalid dates.

## 2. Mating-apiary list indicator

- [ ] 2.1 Add a right-aligned red, keyboard-focusable exclamation mark to hive cards when the helper returns a reason, with the reason exposed on hover and focus; verify with Playwright that each reason is visible, non-alert conditions show no mark, and activating the marker does not open the hive card.
