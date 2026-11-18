# Design

## Context

See proposal.md - Why. Existing E2E tests (`e2e/beelog.spec.js`) and Elm unit tests (`frontend/tests/ApiaryTest.elm`) provide coverage but can be further aligned with OpenSpec requirements across all capabilities (`hives`, `mating-apiaries`, `settings-and-user`, `nfc-and-data`, `testing-and-ci`).

## Goals / Non-Goals

**Goals:**
- Formalize test requirements as OpenSpec delta specs.
- Map existing Playwright and Elm tests to specific capability requirements.
- Expand test coverage for any uncovered edge cases (form validations, error states, responsive layout).

**Non-Goals:**
- Rewriting the entire application architecture.
- Replacing existing testing frameworks (Playwright and elm-test).

## Decisions

- **Keep Playwright and elm-test:** Reuse existing robust testing tools already configured in CI (`.github/workflows/ci.yml`).
- **Feature-aligned test suites:** Group test scenarios according to OpenSpec capability specs.

## Risks / Trade-offs

- [Test Flakiness] → Mitigation: Use robust locators and proper waiting conditions in Playwright.
