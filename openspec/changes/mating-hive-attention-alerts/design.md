# Design

## Context

The mating-apiary list is rendered by `Views.Trutowisko.ulikListView`; each row is a card built by `ulikCardView`. `UlikWeselny` already carries its state and expected hatch and mating dates, while `Model.currentDate` supplies today's date and `Model.hatchingToMatingDays` is the existing interval setting. The existing timeline already parses date strings and falls back when a date is missing or invalid.

## Goals / Non-Goals

**Goals:**
- Derive an attention reason from the hive's current state and applicable expected date.
- Display a red exclamation mark at the right end of the card header and expose the same reason through a native tooltip and keyboard focus.
- Keep the alert derived from existing data, without changing persistence or lifecycle transitions.

**Non-Goals:**
- Alerts for empty hives, already inseminated queens, or conditions beyond the three requested cases.
- Notifications outside the mating-apiary list or changes to the timeline and date configuration.

## Decisions

- Use a small pure helper in `Views.Trutowisko` that returns an optional Polish reason. `bezmatek` always returns a reason; `z_matecznikiem` compares `expectedHatchDate` with `model.currentDate`; `matka_wygryziona` compares `expectedMatingDate` with `model.currentDate`. Other states do not alert.
- Treat a date as overdue only when it is strictly earlier than today's date. Compare parsed calendar dates, not timestamps, so a due date remains valid through that day. If either date is missing or cannot be parsed, do not infer an overdue alert.
- Use a semantic, focusable element with `title` and an accessible label for the red `!`. Place it in a flex header on the right side of each card so it does not overlap the hive name. Prevent its interaction from triggering card navigation if the element needs pointer handling.

## Risks / Trade-offs

- [The model's current date may be unset or invalid] → Suppress date-based alerts until both dates parse; the Bezmatek alert remains available.
- [A visually positioned marker may be hard to discover on touch screens] → Keep the reason available as the element's accessible label and native title; touch-specific persistent disclosure is outside this request.

## Migration Plan

No data migration is needed. Deploying the view change enables the derived indicators immediately; reverting the frontend removes them without affecting stored data.
