# Design

## Context

See `proposal.md` for motivation and `specs/settings-and-user/spec.md` for required behavior. The application is an Elm `Browser.element` app initialized by `frontend/src/index.js`. Elm owns the current view and settings model; ports load and merge user settings in Firestore. At startup, JavaScript currently passes browser preferences as Elm flags, while the authenticated user's settings arrive asynchronously.

Visible labels are currently embedded in `Main.elm` and individual view modules. The current view tree also includes queen-rearing and separate apiary routes, so the translation context must reach every rendered view, including views added after the original proposal was written.

## Goals / Non-Goals

**Goals:**

- Establish one typed language value in the Elm model and one translation record for each render.
- Apply the browser's saved language before the first render, then reconcile it with the authenticated user's Firestore setting.
- Keep legacy settings readable and preserve unrelated fields when saving language changes.
- Make missing translation entries visible to tests rather than silently falling back to Polish.

**Non-Goals:**

- Translate apiary, hive, breed, or other user-entered data.
- Add languages beyond Polish and English, automatic browser-language detection, or a translation service.
- Change date/number formatting rules beyond translating UI labels and messages.

## Decisions

### Represent language as a closed Elm type

Add `Language = PL | EN` to `Types.Core`. Keep language as an explicit field in `Model` and `UserSettings`. Decode Firestore strings with a small decoder that maps `"en"` to `EN` and maps `"pl"`, missing values, and unknown values to `PL`; encode the same stable lowercase codes. This prevents unsupported values from entering view logic and keeps the legacy fallback deterministic.

An open string or a dictionary keyed by arbitrary language codes was considered, but would make unsupported values possible throughout the application and would not fit the two-language requirement.

### Keep translations in a static Elm record

Create `I18n.Translations` as a record with named fields and provide `translationsFor : Language -> Translations`. Derive the active record once in `Main.view` and pass it explicitly to the root and child views. Dynamic labels should use the same translation fields with Elm string composition or small formatting helpers; domain values and user-entered text remain unchanged.

A runtime dictionary was considered, but named fields give the Elm compiler a checkable contract when views or translation keys change. Since Elm cannot reflect over record fields, expose a helper such as `allTranslationValues : Translations -> List String`; unit tests can assert that both language tables contain no empty values.

### Bootstrap from localStorage and reconcile with Firestore

Read `beelog_language` in `index.js` before `Elm.Main.init` and pass its validated code in `Flags`. Invalid or absent values become `pl`. This provides the first render without waiting for authentication or Firestore.

When a user selects a language, update `Model.language` immediately and send it through a port. JavaScript writes the selected code to localStorage and persists it with the existing user-settings merge path. On sign-in, the decoded Firestore settings become authoritative for that account and update the model and localStorage. If the document has no language field, the decoder supplies `PL`; it must not replace or reset any other stored setting. A language change therefore uses the existing settings document and merge behavior rather than a separate collection or migration.

Persisting only in Firestore was considered, but it would leave the startup screen in the wrong language until the network responds. Persisting only in localStorage was also rejected because it would not follow a user across browsers or devices.

### Keep rendering decisions in Elm and storage decisions in JavaScript

The selector emits `ChangeLanguage Language`; Elm changes the current model and requests persistence through a port. JavaScript remains responsible for localStorage and Firestore, consistent with the current settings architecture. Do not put translated strings in JavaScript or duplicate language state there beyond the serialized browser preference.

Pass translations as explicit view arguments instead of introducing a global translation module state or duplicating a language switch in each view. Cover all view modules currently rendered by `Main`, including the queen-rearing view, the split apiary views, settings, navigation, and inline messages.

## Risks / Trade-offs

- **A large, cross-view translation sweep can miss a literal** → Keep the translation record as the only source for visible text, add both-language view scenarios, and use an explicit completeness helper in Elm tests.
- **The browser preference and account preference can differ at sign-in** → Use localStorage only for the initial render; after settings load, apply the authenticated account's decoded value and refresh localStorage.
- **A save can fail after the UI changes language** → Keep the immediate language change for responsiveness, report persistence errors through the existing error path, and retain localStorage as the browser fallback.
- **Legacy or malformed Firestore values could break decoding** → Treat absent and unrecognized language codes as Polish without changing any other setting.

## Migration Plan

No bulk migration is required. Existing settings documents without `language` decode as Polish and remain intact. New language selections are merged into the existing settings document. Existing clients that do not know the new field continue to ignore it. Rollback can remove the selector and language-specific view plumbing; the extra Firestore field and localStorage key can remain safely ignored.
