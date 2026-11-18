# Proposal: Comprehensive Test Scenarios

## Why
Establish robust test coverage across all features, including Playwright E2E scenarios, Elm unit tests, and summary test coverage reporting.

## What Changes
- Add summary test coverage collection (`dodaj test cover`).
- Implement comprehensive Playwright E2E test scenarios for authentication, settings, commercial apiaries, summaries, moving uliks, advanced mating apiaries, dark mode / responsiveness, and form validation.
- Implement Elm unit test scenarios for robust decoders, user settings, short labels, korpus editor logic, date calculation, and history limiting.

## Capabilities

### Modified Capabilities
- `testing-and-ci`: Comprehensive E2E test suite and Elm unit test suites.

## Impact
`e2e/beelog.spec.js`, `frontend/tests/ApiaryTest.elm`, CI configuration.
