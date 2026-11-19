# Design

## Context

The frontend is Elm rendered through Vite. Settings currently mix inline style attributes with a consistent but narrow pattern of labelled checkboxes; queen-rearing numeric fields have little shared styling. See proposal.md for motivation and `specs/settings-and-user/spec.md` for the observable requirements.

## Goals / Non-Goals

**Goals:**
- Add Tailwind CSS to the existing Vite build and make its generated styles available to Elm-rendered markup.
- Establish reusable utility-class patterns for settings numeric fields and optional-module toggle rows.
- Preserve dark-mode readability and existing form behavior.

**Non-Goals:**
- Redesign every screen or migrate every inline style in the application in this change.
- Change settings validation, persistence, labels, or navigation behavior.

## Decisions

- Integrate Tailwind CSS using its Vite plugin and CSS `@import` entry point, keeping the styling pipeline in the existing Vite build rather than adding a separate CSS build command. Tailwind's current Vite setup documents this plugin and CSS entry pattern ([official installation guide](https://tailwindcss.com/docs/installation/using-vite)).
- Apply utility classes to the Settings view first, replacing relevant inline styles for number fields and module toggle rows. This creates a usable standard while keeping the migration scoped and reviewable.
- Use shared class sets for numeric inputs and toggle rows, with explicit light/dark variants compatible with the existing `model.darkMode` state. Existing labels, `data-testid` attributes, and Elm message handlers remain attached to the same controls.
- Let Tailwind scan the Elm source directory so utility classes embedded in Elm strings are included in generated CSS.

## Risks / Trade-offs

- Tailwind's class detection may miss dynamically assembled class names → keep classes as complete static strings in Elm and verify the production build includes the expected controls' styles.
- A partial migration leaves other views styled with inline attributes → limit this change to settings controls and leave broader screen redesign for a separately scoped effort.
- Utility classes can conflict with browser defaults or existing global CSS → check control appearance in both themes and retain explicit focus and sizing styles.

## Migration Plan

Add the Tailwind Vite integration and stylesheet entry, migrate the specified settings controls, then build and review the Settings view. Rollback consists of removing the plugin/import and restoring the prior control styles; no persisted data migration is required.
