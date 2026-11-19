# Tasks

## 1. Action predicate and Elm state

- [ ] 1.1 Add a dedicated boolean model field and toggle message for `Tylko wymagające akcji`, initialize it unchecked, and verify the Elm application compiles through `make elm_test`.
- [ ] 1.2 Update the shared mating-hive attention/date predicate so applicable dates equal to today count as actionable while existing queenless, overdue, and invalid-date behavior remains correct; add focused Elm tests and verify them with `make elm_test`.

## 2. Mating-apiary list UI and filtering

- [ ] 2.1 Add an accessible checkbox at the top of the mating-hive list and combine its predicate with the existing state filter; verify unchecked behavior, due-today, overdue, queenless, future-date, and combined-filter cases with `make e2e_test PLAYWRIGHT_ARGS='e2e/beelog.spec.js'`.
- [ ] 2.2 Preserve the existing attention markers and add a clear empty result state if the action-only filter has no matches; verify the list remains navigable and hives are not modified using the focused Playwright test through `make e2e_test PLAYWRIGHT_ARGS='e2e/beelog.spec.js'`.

## 3. Validation

- [ ] 3.1 Run the repository OpenSpec validation and confirm the new change has no schema or strict-format errors with `make test_openspec`.
