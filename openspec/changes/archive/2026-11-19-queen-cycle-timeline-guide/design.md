# Design

## Context

The list timeline is rendered by `ulikTimelineView` in `frontend/src/Views/Trutowisko.elm`. Its date positions and segments are calculated from the expected hatch date, expected mating date (or configured fallback), and the date 30 days after hatching. Existing segment colors are yellow before mating, green from expected mating to day 30, and red after day 30. This change adds explanation without changing those calculations.

## Goals / Non-Goals

**Goals:**
- Let users inspect the meaning of the timeline colors in place.
- Make the information control operable by keyboard and identifiable to assistive technology.
- Keep the card compact until the user requests the explanation.

**Non-Goals:**
- Changing the biological timing assumptions, date calculations, or alert rules.
- Adding stored user preferences or new data fields.

## Decisions

- Use the native disclosure element (`details`/`summary`) to track open/closed state per timeline without changing the application model. (Alternative: add a global Elm message and per-ulik model state; unnecessary for a local, transient explanation.)
- Render a compact text legend with colored swatches, mapping the existing axis segments to their current date ranges and describing red as exceeding the day-30 deadline.

## Risks / Trade-offs

- [Color alone may be hard to distinguish] → Pair each swatch with a written status description.
- [Cards may become taller when multiple legends are open] → Keep the legend collapsed by default and render it only on request.

## Migration Plan

No data migration is required. Rollback consists of removing the disclosure UI and its view state/message.
