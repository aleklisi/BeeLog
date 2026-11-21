# Design

## Context

The frontend is Elm rendered through Vite, with Tailwind utilities available in selected views and inline styles still common elsewhere. Theme colors are often chosen from `model.darkMode`. Mating hive status actions live in `Views.UlikDetail`; queen-cycle timeline segments and their legend are rendered in `Views.Trutowisko` and `Views.UlikDetail`. See proposal.md for motivation and `specs/ui-theme-colors/spec.md` for observable requirements.

## Goals / Non-Goals

**Goals:**
- Establish readable reusable light/dark color patterns for common actions, surfaces, controls, and destructive actions in the affected frontend.
- Give mating hive states a single visual mapping shared by the detail actions and status indicators, and make the current state apparent.

**Non-Goals:**
- Change hive status transitions, stored data, or queen-cycle date calculations.
- Rebuild the frontend styling system or add a styling dependency.

## Decisions

- Keep styling in Elm and use the Tailwind utilities already configured by the project, retaining inline theme-dependent values where existing views require them. Avoid a new component or CSS framework for this focused visual change.
- Use the timeline's established state colors as the source of truth for mating status controls: red for queenless (B), yellow for queen cell (M), dark yellow for unmated queen (N), and green for mated queen (UNC). Where timeline segments mean elapsed periods rather than hive states, preserve their existing meanings.
- Centralize status-to-color class selection in a small Elm helper so status controls and visible state labels cannot drift apart. Mark active status controls semantically with `aria-pressed` and visually with a distinct border/ring; keep available transitions clearly actionable.
- Prefer deep green backgrounds with light text and light lime backgrounds with dark text. Give destructive actions red backgrounds and explicit dark-mode variants. Apply explicit hover/focus treatments to interactive controls.
- Cover the shared UI patterns in the views using them rather than mechanically replacing every inline style; preserve existing behavior and test IDs.

## Risks / Trade-offs

- Existing timeline colors encode lifecycle periods and may not contrast equally well as button fills → choose accessible Tailwind shades for controls while retaining the same recognizable color family and verify both themes.
- Elm/Tailwind class extraction can omit dynamically assembled classes → use complete static class strings or ensure the scanning safelist includes each used class.
- The frontend has several independent inline-style conventions → limit changes to relevant controls and surfaces while keeping the specified common palette coherent.

## Migration Plan

Update relevant Elm views and status color helpers, then run the focused Elm and OpenSpec checks. No persisted data migration is needed. Rollback consists of reverting the view and style changes.
