# Proposal

## Why

The Settings screen currently shows all four sections (Ogólne, Pasieczyska towarowe, Trutowiska, Queen Rearing) fully expanded at all times. As the number of configurable options grows, this makes the page long and hard to scan. Users who care only about one section must scroll past everything else.

Collapsible sections give users control over what they see, reduce visual clutter, and make the Settings screen easier to navigate on both desktop and mobile.

## What Changes

- Each settings section heading becomes a clickable toggle button.
- Clicking a collapsed section header expands it and shows its content; clicking an expanded header collapses it and hides its content.
- The header displays a circular chevron icon on the right: **∨** when collapsed, **∧** when expanded.
- All sections start expanded by default so existing users experience no regression.
- The expanded/collapsed state is kept in `model.expandedSettingsSections : List SettingsSection` — a plain in-memory list; it is intentionally **not** persisted to Firestore or localStorage (state resets on each visit).

## Capabilities

### Modified Capabilities

- `settings-and-user`: Settings sections are now collapsible. Each section header acts as a toggle button with a chevron indicator and appropriate `aria-expanded` attribute.

## Impact

- `frontend/src/Types/Core.elm` — new `SettingsSection` union type (`SectionOgolne | SectionPasieczyskaTowarowe | SectionTrutowiska | SectionQueenRearing`); new field `expandedSettingsSections : List SettingsSection` on `Model`; new message `ToggleSettingsSection SettingsSection`.
- `frontend/src/Main.elm` — initialise `expandedSettingsSections` with all four sections expanded; handle `ToggleSettingsSection` in `update` by toggling membership in the list.
- `frontend/src/Views/Settings.elm` — replace static `<h2>` section headings with clickable `<button>` elements; conditionally render section content based on `isExpanded`; add chevron icon.
- `e2e/beelog.spec.js` — Playwright scenarios covering collapse, expand, and default-expanded behaviour for each section.
