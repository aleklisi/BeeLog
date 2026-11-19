# Proposal

## Why

BeeLog is currently Polish-only. As the app grows, users who prefer to work in English — or who share access with non-Polish speakers — have no way to switch the UI language. Adding a language setting removes this barrier without touching existing Polish defaults.

## What Changes

- Add a `language` field to `UserSettings` with two supported values: `"pl"` (Polish, default) and `"en"` (English).
- Expose a language selector in the **Settings → General** section, below the dark-mode toggle.
- Introduce a typed `Language` union (`PL | EN`) in `Types.Core` and pass the current language through the view layer so every view can render labels from the correct translation record.
- Create an `I18n` module (`frontend/src/I18n.elm`) that holds two top-level translation records — one per language — covering every user-visible string in the application (labels, headings, button text, placeholders, tooltips, error messages, navigation items).
- Persist the chosen language in Firestore as part of the user settings document (same path as other settings). Load it on sign-in with a safe default of `"pl"` for existing documents that do not yet contain the field.
- Store the last-used language in `localStorage` under the key `beelog_language` so it is applied immediately on page load before Firestore responds.
- Update all existing views (`ApiaryList`, `HiveDetail`, `UlikDetail`, `Settings`, `Trutowisko`, `PasieczyskoTowarowe`, `Main`) to accept and use the `I18n` translation record instead of hard-coded Polish strings.

## Capabilities

### New Capabilities

- `app-i18n`: Translation record, `Language` type, `I18n` module with full PL and EN string tables.

### Modified Capabilities

- `settings-and-user`: Add `language` field to `UserSettings`, decoder, encoder, Firestore merge, and localStorage bootstrap.
- `apiary-views`: Pass translation record; replace hard-coded Polish strings with `t.fieldName`.
- `hive-views`: Pass translation record; replace hard-coded Polish strings with `t.fieldName`.
- `mating-apiary-views`: Pass translation record; replace hard-coded Polish strings with `t.fieldName`.
- `main-navigation`: Pass translation record to hamburger menu and top-level layout strings.

## Impact

- `frontend/src/Types/Core.elm` — new `Language` type, `language : Language` on `UserSettings` and `Model`.
- `frontend/src/I18n.elm` — new module with `Translations` record type and `translationsFor : Language -> Translations`.
- `frontend/src/Types/Decoders.elm` — decode/encode `language` field with `"pl"` fallback.
- `frontend/src/index.js` — read/write `beelog_language` in localStorage; include `language` in settings Firestore document.
- `frontend/src/Views/Settings.elm` — language selector UI; all labels via `t.*`.
- `frontend/src/Views/ApiaryList.elm`, `HiveDetail.elm`, `UlikDetail.elm`, `Trutowisko.elm`, `PasieczyskoTowarowe.elm` — all labels via `t.*`.
- `frontend/src/Main.elm` — derive `t` from `model.language`; pass to all view calls.
- `frontend/tests/` — Elm unit tests for `translationsFor` completeness (every key non-empty in both languages) and language decoder fallback.
- `e2e/beelog.spec.js` — Playwright scenarios for language selector persistence and UI string switching.
