# Design

## Context

BeeLog has several active changes that define button colors in specific areas, while the main specs also contain local rules for settings controls and theme colors. The implementation should build on the existing Elm and Tailwind styling approach and preserve behavior, translations, and domain-specific status colors. See `proposal.md` for motivation and `specs/` for the required behavior.

## Goals / Non-Goals

**Goals:**

- Establish one shared set of semantic component styles that views can reuse.
- Make action placement and responsive behavior predictable without changing what actions do.
- Migrate existing views in coherent groups and reconcile the two active button-color proposals.

**Non-Goals:**

- Redesigning BeeLog's brand palette or changing domain colors used to convey hive and queen-rearing status.
- Changing application workflows, data models, translations, or navigation behavior.
- Replacing Elm, Tailwind, or the current styling setup.

## Decisions

### Define semantic styles before migrating views

Create a small shared vocabulary for primary, secondary, neutral, destructive, and domain-specific action styles, plus shared treatments for form controls, cards, section headings, and grouped actions. Semantic names let a view express intent without embedding one-off color and spacing combinations. Keep the tokens and classes in the repository's existing shared styling location rather than introducing a new styling dependency.

**Alternative considered:** Normalize each view independently. That would preserve local duplication and make later corrections drift again.

### Preserve domain-specific colors as explicit exceptions

General actions use the shared semantic palette. Status controls and specialized operations such as NFC or voice recording may keep a distinct domain color when that color already communicates a meaningful state or capability; they still use shared sizing, focus, contrast, and placement rules. This prevents the general button system from obscuring status meaning.

**Alternative considered:** Force every action into the same green/red palette. That would erase useful distinctions already defined by the product and existing specs.

### Organize actions by context and consequence

Form actions should be grouped at the end of the form with the commit action visually primary. Item actions stay attached to their item. Destructive actions are visibly distinct and separated enough to reduce accidental activation. At narrow widths, groups may wrap or stack while retaining their order and labels.

**Alternative considered:** Enforce one global left/right alignment for every action group. Different contexts (dialogs, forms, cards, lists) need different alignment while retaining the same hierarchy.

### Migrate by shared component and view family

First apply the shared styles to reusable controls, then migrate settings and forms, followed by lists/detail views and dialogs. During that pass, reconcile `settings-buttons-color-guidelines` and `commercial-apiary-hive-button-colors` with the shared roles and retain their domain-specific exceptions. Avoid changing business logic in the styling migration.

**Alternative considered:** Change every view in one pass. Smaller view-family changes are easier to review and make visual regressions easier to localize.

## Risks / Trade-offs

- [Existing views use inline or locally composed styles] → Inventory repeated button and component patterns before migration; replace them with shared styles in view-family slices.
- [Semantic styles can still vary in edge cases] → Document allowed domain-specific exceptions and ensure they retain shared accessibility and sizing behavior.
- [Responsive wrapping can shift familiar layouts] → Preserve action order and validate representative narrow and wide layouts during implementation.
- [Two active proposals overlap with the new standard] → Update or align their implementation tasks as part of migration; do not maintain competing class conventions.

## Migration Plan

1. Inventory repeated component and button patterns and map each to a semantic role.
2. Add shared styles and migrate common controls, confirming that existing labels and behavior remain intact.
3. Migrate view families and align the active button-color changes with the shared styles.
4. Remove superseded one-off style combinations after all affected views use the shared conventions.
5. Roll back a view-family migration by restoring that view's previous classes; shared styles can remain until no migrated view depends on them.
