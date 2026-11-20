# Design

## Context

BeeLog is a web-based beekeeping management application built with Elm and JavaScript (Vite), utilizing Google Firebase for Authentication and Firestore cloud database storage.
The application processes personal data such as user email, authentication tokens, and user-generated beekeeping records. Browser storage is utilized for authentication state (Firebase Auth tokens in IndexedDB/sessionStorage), UI preferences (`beelog_darkMode`, `beelog_language` in `localStorage`), and consent decisions (`beelog_consent` in `localStorage`).

Under European Union General Data Protection Regulation (GDPR / RODO - Regulation (EU) 2016/679) and Polish Telecommunications Law / electronic communications regulations (Art. 173 Prawa Telekomunikacyjnego / Prawo Komunikacji Elektronicznej), the application must provide transparent, easily accessible information regarding:
1. Personal data processing, legal bases, processing purposes, data retention, third-party sub-processors (Google Firebase), and user rights (access, rectification, erasure, data portability, complaint to the Polish Data Protection Authority / PUODO).
2. The use of cookies and local browser storage (distinguishing strictly necessary technical storage from optional storage).
3. The ability for users to express consent, reject optional processing, and revisit or modify their privacy choices at any time.

## Goals / Non-Goals

**Goals:**

- Provide an accessible, user-friendly Privacy Policy and Cookie / Storage disclosure dialog available in Polish and English.
- Make the privacy policy accessible to unauthenticated users on the login view and to authenticated users within the application (via Settings).
- Provide a non-intrusive consent notice banner on initial application visit informing users about local storage usage, with options to accept only necessary storage or all storage.
- Provide a dedicated "Prywatność i zgody" / "Privacy & Consent" section in Settings allowing users to review storage categories, view the Privacy Policy, and toggle optional telemetry/analytics.
- Persist consent choices in `localStorage` under `beelog_consent` and synchronize with Elm via ports and flags.
- Document and respect all data subject rights under GDPR, integrating with existing self-service account deletion.

**Non-Goals:**

- Integrating third-party advertising or commercial tracking networks (BeeLog does not employ advertising trackers).
- External CMS hosting for privacy legal texts; texts are versioned within the repository and translated natively for zero-latency and offline readiness.

## Decisions

- **Storage categorization**:
  - *Strictly necessary storage*: Firebase Authentication credentials/tokens in IndexedDB, UI preferences (`beelog_darkMode`, `beelog_language`), and consent state (`beelog_consent`). Necessary for the application to function and remember user settings; always active.
  - *Optional diagnostics/analytics*: Off by default (opt-in); configurable in the consent banner and in Settings.
- **Privacy Policy Modal Dialog**:
  - Implemented as a reusable Elm view overlay (`showPrivacyPolicy : Bool` in `Model`).
  - Accessible from the login screen (footer link/button `data-testid="login-privacy-policy"`) and from Settings (`data-testid="open-privacy-policy"`).
  - Clear sections covering: Data Controller (Administrator danych), Data Collected & Purposes, Legal Bases (Art. 6(1)(b), 6(1)(f), 6(1)(a) RODO), Cookies & Storage, Data Retention, Third-Party Processors (Google Firebase/Cloud), and Data Subject Rights (including PUODO contact).
- **Consent Banner**:
  - Displayed when no consent record is found in `localStorage` (`model.consentDecided == False`).
  - Contains actions: "Tylko niezbędne" / "Only necessary" (`data-testid="consent-necessary"`), "Zezwól na wszystkie" / "Allow all" (`data-testid="consent-all"`), and a link to view the Privacy Policy (`data-testid="consent-privacy-policy"`).
  - Dismissing or accepting persists `{ necessary: true, analytics: Bool, timestamp: Int }` in `localStorage` and updates Elm state.
- **Settings Integration**:
  - Add `SectionPrywatnosc` to `ExpandedSettingsSection` with toggle button `settings-section-toggle-prywatnosc`.
  - Inside the section:
    - Status badge for Essential Storage (Zawsze aktywne / Always active).
    - Toggle for Optional Diagnostics / Analytics (`data-testid="analytics-toggle"`).
    - Button to open full Privacy Policy (`data-testid="open-privacy-policy"`).
- **Elm Ports & Flag Initialization**:
  - `flags` in `Elm.Main.init` receives `consent` object (`{ necessary: Bool, analytics: Bool, decided: Bool }`).
  - Elm sends updated preferences to JS via `saveConsent` port, which updates `localStorage.setItem('beelog_consent', ...)`.

## Risks / Trade-offs

- [Risk: Banner obstructs UI controls on mobile screens] → Position as a sticky bottom bar with clear, compact buttons and responsive styling.
- [Risk: Desynchronization of consent state between tabs or reloads] → Keep `localStorage` as source of truth initialized via flags and updated via ports on change.

## Migration Plan

1. Implement Elm types, messages, translations (PL and EN), view modals, and banner.
2. Update JavaScript index (`frontend/src/index.js`) to parse `localStorage.getItem('beelog_consent')`, pass it in flags, and listen on `saveConsent` port.
3. Add Elm tests in `frontend/tests/` and Playwright E2E tests in `e2e/privacy-and-consent.spec.js`.
4. Run full test suite (`make all_test`) and validate OpenSpec strictly.
5. Archive change using `openspec archive privacy-and-consent`.
