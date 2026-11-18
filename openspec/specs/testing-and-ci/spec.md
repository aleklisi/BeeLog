# Testing and CI

## Purpose
Ensures software quality through automated unit testing (Elm test), end-to-end testing (Playwright), and continuous integration on GitHub Actions.

## Requirements

### Requirement: Continuous Integration and Automated Tests
The project SHALL ensure software quality through automated test suites in CI.

#### Scenario: GitHub Actions CI Execution
- **WHEN** code is pushed or PR is opened on GitHub
- **THEN** GitHub Actions MUST automatically execute `elm-test` and Playwright E2E tests ensuring all tests pass successfully.
