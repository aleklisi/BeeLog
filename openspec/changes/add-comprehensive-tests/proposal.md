# Proposal: Add Comprehensive Unit and Integration Tests

## Why
To ensure high software quality and robust coverage across all project capabilities, existing Playwright E2E tests and Elm unit tests should be formally mapped to OpenSpec specifications, improved, and expanded to cover all requirements defined in `openspec/specs/`.

## What Changes
- Formalize test specifications in delta specs covering hives, mating apiaries, settings/user, NFC/data, and CI testing.
- Review and refine existing Playwright E2E test scenarios (`e2e/beelog.spec.js`) for authentication, apiary management, hive korpus editor, mating hives lifecycle, and navigation.
- Review and refine existing Elm unit tests (`frontend/tests/ApiaryTest.elm`) for robust JSON decoders, date calculations, short labels, and history limits.
- Ensure test execution success in CI (GitHub Actions).

## Capabilities

### Modified Capabilities
- `testing-and-ci`: Comprehensive test coverage, Playwright E2E test improvements, and Elm unit test enhancements.

## Impact
`e2e/beelog.spec.js`, `frontend/tests/ApiaryTest.elm`, CI pipelines.
