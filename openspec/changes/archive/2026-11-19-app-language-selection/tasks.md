# Tasks

## 1. Types, I18n module, and settings persistence

- [x] 1.1 Add `Language` union type (`PL | EN`) to `Types.Core`; add `language : Language` to `UserSettings` and `Model`; derive the initial value from the `beelog_language` localStorage key passed as a flag from `index.js`.
- [x] 1.2 Create `frontend/src/I18n.elm` with a `Translations` record covering every user-visible string in the application and a `translationsFor : Language -> Translations` function returning the full PL and EN records.
- [x] 1.3 Extend `Types.Decoders` to decode `language` from Firestore settings (`"pl"` / `"en"` strings, defaulting to `PL` for missing or unrecognised values) and encode it back on save.
- [x] 1.4 Update `frontend/src/index.js` to (a) read `beelog_language` from localStorage and pass it as a flag to Elm, (b) write `beelog_language` to localStorage whenever the language changes, and (c) include `language` in the Firestore settings document on read and write.
- [x] 1.5 Add a `ChangeLanguage Language` message to `Types.Core.Msg`; handle it in `Main.elm` to update `model.language`, persist via port, and re-derive the active translation record.

## 2. Language selector UI in Settings

- [x] 2.1 Add a language selector control to the **General** section of `Views.Settings` (below the dark-mode toggle), rendering a `<select>` with options `("pl", "Polski")` and `("en", "English")`, pre-selected to the current language, tagged with `data-testid="language-select"`, and emitting `ChangeLanguage` on change.
- [x] 2.2 Replace all hard-coded Polish string literals in `Views.Settings` with `t.*` keys from the passed-in `Translations` record; update the function signature to accept `Translations`.

## 3. Translate all existing views

- [x] 3.1 Update `Views.ApiaryList` to accept and use `Translations`; replace every hard-coded string with the matching `t.*` key; add corresponding keys to the `Translations` record and both language tables.
- [x] 3.2 Update `Views.HiveDetail` to accept and use `Translations`; replace every hard-coded string; add keys.
- [x] 3.3 Update `Views.UlikDetail` to accept and use `Translations`; replace every hard-coded string; add keys.
- [x] 3.4 Update `Views.Trutowisko` to accept and use `Translations`; replace every hard-coded string; add keys.
- [x] 3.5 Update `Views.PasieczyskoTowarowe` to accept and use `Translations`; replace every hard-coded string; add keys.
- [x] 3.6 Update `Main.elm` login view, navigation shell, error/success banners, and any inline strings to use `Translations`; derive `t = translationsFor model.language` once at the top of the `view` function and thread it to all view calls.

## 4. Tests

- [x] 4.1 Add Elm unit tests in `frontend/tests/` verifying that `translationsFor PL` and `translationsFor EN` both return records where every field is a non-empty string.
- [x] 4.2 Add Elm unit tests for the `language` decoder: `"pl"` → `PL`, `"en"` → `EN`, missing field → `PL`, unknown value → `PL`.
- [x] 4.3 Add Playwright E2E scenarios in `e2e/beelog.spec.js` covering language selection, refresh persistence, sign-in persistence, and translated navigation labels.

## 5. Integration verification

- [x] 5.1 Run `make elm_test`; verify all new and existing Elm tests pass.
- [x] 5.2 Run `make e2e_test`; verify all new and existing E2E scenarios pass.
- [x] 5.3 Run `make all_test`; verify the full suite is green.
