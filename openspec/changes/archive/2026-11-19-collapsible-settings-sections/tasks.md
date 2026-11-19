# Tasks

## 1. Types and state

- [x] 1.1 Add `SettingsSection` union type (`SectionOgolne | SectionPasieczyskaTowarowe | SectionTrutowiska | SectionQueenRearing`) to `Types.Core`.
- [x] 1.2 Add `expandedSettingsSections : List SettingsSection` field to `Model` in `Types.Core`.
- [x] 1.3 Add `ToggleSettingsSection SettingsSection` message to `Msg` in `Types.Core`.

## 2. Update and init

- [x] 2.1 Initialise `expandedSettingsSections` in `Main.elm` with all four sections present (all expanded by default).
- [x] 2.2 Handle `ToggleSettingsSection section` in `Main.elm` `update`: add the section if absent, remove it if present.

## 3. Settings view

- [x] 3.1 Replace each static `<h2>` section heading in `Views.Settings` with a `<button>` that emits `ToggleSettingsSection` on click.
- [x] 3.2 Add a circular chevron icon (∨ / ∧) on the right side of each section header button, reflecting collapsed / expanded state.
- [x] 3.3 Set `aria-expanded` attribute on each header button (`"true"` / `"false"`).
- [x] 3.4 Conditionally render section body only when the section is in `model.expandedSettingsSections`; render `text ""` otherwise.
- [x] 3.5 Add `data-testid` attributes on header buttons (`settings-section-toggle-ogolne`, `settings-section-toggle-pasieczyska`, `settings-section-toggle-trutowiska`, `settings-section-toggle-queen-rearing`) and on section bodies (`settings-section-ogolne`, `settings-section-pasieczyska`, `settings-section-trutowiska`, `settings-section-queen-rearing`).

## 4. Tests

- [x] 4.1 Add Playwright E2E scenarios in `e2e/beelog.spec.js` covering:
  - All four section bodies are visible on initial load (default expanded).
  - Clicking a toggle button hides the section body and shows the ∨ icon.
  - Clicking the toggle button again shows the section body and shows the ∧ icon.

## 5. Spec update

- [x] 5.1 Update `openspec/specs/settings-and-user/spec.md` to document the collapsible-sections requirement.

## 6. Verification

- [x] 6.1 Run `make elm_test`; verify compilation succeeds and all existing tests pass.
