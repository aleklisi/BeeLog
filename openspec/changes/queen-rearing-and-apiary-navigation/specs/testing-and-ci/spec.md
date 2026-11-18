# Spec Delta

## MODIFIED Requirements

### Requirement: Continuous Integration and Automated Tests
The project SHALL ensure software quality through automated Elm unit tests and Playwright end-to-end tests in CI. Each new or changed user-facing requirement SHALL have automated test coverage at the appropriate level.

#### Scenario: GitHub Actions CI Execution
- **WHEN** code is pushed or a pull request is opened on GitHub
- **THEN** GitHub Actions MUST execute the Elm and Playwright test suites and require them to pass

#### Scenario: Test queen-rearing domain behavior
- **WHEN** the Elm unit test suite runs
- **THEN** it covers schedule date calculations, count validation, batch transition rules, urgency classification, and batch ordering

#### Scenario: Test navigation and apiary views end to end
- **WHEN** the Playwright end-to-end test suite runs
- **THEN** it covers menu visibility and operation, persisted independent feature settings, type-specific apiary lists and creation, and fallback navigation after disabling the current view

#### Scenario: Test queen-rearing workflows end to end
- **WHEN** the Playwright end-to-end test suite runs
- **THEN** it covers batch creation, resource reservation and release, completion through incubator and direct paths, zero accepted cells, and overdue and upcoming alerts
