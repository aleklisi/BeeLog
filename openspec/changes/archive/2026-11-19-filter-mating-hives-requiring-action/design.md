# Design

## Context

The mating-hive view already has a state selector in `frontend/src/Views/Trutowisko.elm` and derives alert reasons from the hive state and expected dates. The current date is already available in the Elm model. The new behavior should reuse that domain logic while adding a separate transient view preference.

## Goals / Non-Goals

**Goals:**

- Add a clear, accessible checkbox in the list controls with an unchecked initial value.
- Apply the action-only predicate together with the existing state predicate.
- Treat today and earlier as actionable for date-based attention checks, while retaining the existing queenless and overdue-deadline attention rules.
- Keep the choice scoped to the current in-memory view and ensure it resets to the default when a new model/session starts.

**Non-Goals:**

- No persistence of the checkbox choice in Firestore, local storage, or user settings.
- No changes to the meaning or display of attention alert reasons.
- No changes to commercial-apiary lists or mating-hive records.

## Decisions

1. **Use a dedicated boolean view state.** Add a model boolean and a toggle message rather than encoding the option in the existing state-filter string. This keeps the two independent controls composable and preserves the meaning of existing `SetUlikFilter` behavior.

2. **Filter with the shared attention predicate.** Determine whether a hive is actionable from the existing attention-reason logic, with date comparisons adjusted so an applicable date equal to today qualifies. This avoids duplicating state/date rules in the view and keeps the alert indicator and filter aligned.

3. **Apply predicates in sequence.** First retain hives matching the selected state (or all states), then, when the checkbox is enabled, retain only hives with at least one attention reason. This makes the intersection behavior explicit and leaves the unchecked path equivalent to the current implementation.

4. **Test at both logic and UI levels.** Add Elm tests for today, overdue, future, queenless, and invalid/missing dates, plus an end-to-end scenario covering default unchecked state, filtering, combined state filtering, and restoring the full list.

## Risks / Trade-offs

- [Risk] Changing a shared date comparison could alter existing alert behavior. → Isolate and test the inclusive “today” predicate, then verify the existing alert tests and scenarios remain correct.
- [Risk] A transient checkbox may be surprising after navigation or reload. → Make the default explicit in model initialization and document that persistence is out of scope.
- [Risk] The filtered list may be empty. → Preserve the existing empty-list rendering or add a clear empty-state message during implementation and cover it in the UI test.

## Migration Plan

No data migration is required. Deploy the UI and Elm model changes together; rollback consists of reverting the code and test changes.
