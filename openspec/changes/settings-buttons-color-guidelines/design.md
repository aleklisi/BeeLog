# Design

## Context

See `proposal.md` for motivation. `frontend/src/Views/Settings.elm` contains a back-navigation button, add buttons for configurable lists, section expand/collapse buttons, a theme toggle, list-removal icons, and account-deletion confirmation actions. Shared button rules live in `frontend/src/styles.css`.

## Goals / Non-Goals

**Goals:**
- Give each existing settings button role a stable semantic style that supports both themes.
- Keep focus and hover feedback consistent with the existing shared button system.

**Non-Goals:**
- Change settings behavior, persistence, labels, or navigation.
- Rework non-button form controls or unrelated application views.

## Decisions

- Keep action colors in the shared stylesheet and apply semantic classes from the Elm view. This avoids repeated inline color declarations and makes light/dark variants reviewable together; per-button inline styles are an alternative but can override shared rules and repeat inconsistently.
- Map navigation, add, and theme-toggle actions to dark green with contrasting white text; map section toggles to lime surfaces with readable text; map list removal, account deletion, and cancellation actions to red surfaces with contrasting text. Match both themes to the project's existing CSS/Tailwind setup.
- Give section toggles a lime treatment while preserving their current full-width layout and `aria-expanded` state. Keep destructive list actions visually identifiable and accessible when rendered as compact icon buttons.
- Language selection and module preferences are currently rendered as a select and checkboxes, not as button groups. Keep their behavior and native control presentation out of this button-color change.
- Verify the resulting styles in both themes and by keyboard focus, without changing click handlers or settings state.

## Risks / Trade-offs

- [Existing inline colors can override semantic classes] → Remove or consolidate only the conflicting color declarations on affected settings buttons.
- [A pale lime surface can lose contrast in dark mode] → Use a darker foreground and a separately tuned dark-theme surface; confirm focus remains visible.
