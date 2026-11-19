# Proposal

## Why

Opiekunowie trutowisk potrzebują szybko skupić się na ulikach, których kontrola jest już potrzebna. Obecna lista pokazuje wszystkie uliki i pozwala filtrować je tylko po stanie, więc znalezienie pozycji z terminem przypadającym dziś lub już przekroczonym wymaga ręcznego przeglądania.

## What Changes

- Add a checkbox at the top of the mating-hive list labelled `Tylko wymagające akcji`.
- Keep the checkbox unchecked by default; when unchecked, preserve the current list contents and existing state filter behavior.
- When checked, show only hives whose existing attention rules indicate action is due today or overdue, including a hive with no queen.
- Treat a due date equal to the current date as requiring action, in addition to dates before the current date.
- Keep the filter local to the current mating-apiary view and do not change hive data or attention-alert rules.

## Capabilities

### New Capabilities

<!-- No new capability; this extends the existing mating-apiaries behavior. -->

### Modified Capabilities

- `mating-apiaries`: Add an optional list filter for mating hives requiring action today or overdue.

## Impact

- Mating-hive list view in `frontend/src/Views/Trutowisko.elm`.
- Elm model/update state for the checkbox and its default value.
- Existing `attentionReasons` date and state logic, extended or reused so “today” is included consistently.
- Elm unit tests and Playwright coverage for default, checked, unchecked, due-today, overdue, and non-matching hives.
- No Firestore schema, persistence, or API changes.
