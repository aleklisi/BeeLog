# Tasks: Privacy and consent information

## 1. Specification and legal analysis

- [x] 1.1 Review application data flows, including cookies, browser storage, authentication, analytics, and third-party services.
- [x] 1.2 Specify the privacy policy content and user-facing cookie or similar-technology disclosures in Polish and English.
- [x] 1.3 Specify applicable consent or preference choices, persistence, and how users can revisit them.
- [x] 1.4 Identify any additional notices or user rights that need product support (RODO/GDPR, account erasure, PUODO).
- [x] 1.5 Review detailed requirements against applicable EU and Polish obligations before implementation.

## 2. Technical design and data model

- [x] 2.1 Create technical design document specifying Elm model, JS ports, and localStorage persistence for consent.

## 3. Frontend implementation

- [x] 3.1 Implement privacy policy dialog with full legal disclosures in Polish and English.
- [x] 3.2 Implement user-facing cookie and storage consent banner for initial visitors.
- [x] 3.3 Add Privacy and Consent section to Settings with essential and optional storage controls.
- [x] 3.4 Wire JS ports and localStorage persistence for privacy preferences.

## 4. Verification and OpenSpec completion

- [x] 4.1 Add Elm unit tests and Playwright E2E tests verifying privacy policy, consent banner, and settings controls.
- [x] 4.2 Verify the privacy-specific Elm and E2E tests pass via Make targets; record unrelated failures from `make all_test` without expanding this change to fix them.
- [x] 4.3 Validate and archive the change in OpenSpec.
