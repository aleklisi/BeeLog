# Tasks

## 1. Alert rules

- [x] 1.1 Add a pure attention-reason helper for the three specified states using parsed expected dates and `Model.currentDate`; verify with Elm tests for Bezmatek, each overdue state, due-today/future dates, and missing or invalid dates.
- [x] 1.2 Add a fourth attention condition: state M or N with more than 30 days elapsed since `expectedHatchDate`; verify with Elm tests for both states past the deadline, state within the deadline, and ineligible states (UNC, Bezmatek, Pusty).
- [x] 1.3 Refactor the attention helper to return `List String` (`attentionReasons`) so all simultaneously-met conditions are collected; keep the `Maybe String` wrapper (`attentionReason`) for backwards compatibility; verify with an Elm test that a hive meeting two conditions returns both reasons.

## 2. Mating-apiary list indicator

- [x] 2.1 Add a right-aligned red, keyboard-focusable exclamation mark to hive cards when the helper returns a reason, with the reason exposed on hover and focus; verify with Playwright that each reason is visible, non-alert conditions show no mark, and activating the marker does not open the hive card.
- [x] 2.2 Update `ulikCardView` to use `attentionReasons`; join all reasons with " / " into the `title` and `aria-label` of the single exclamation mark button; show the button only when the list is non-empty.
