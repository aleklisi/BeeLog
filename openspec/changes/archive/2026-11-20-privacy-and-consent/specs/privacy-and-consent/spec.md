# privacy-and-consent Specification

## Purpose

Provide transparent, accessible user-facing privacy notices, cookie and storage disclosures, and consent preference controls in BeeLog in compliance with GDPR / RODO and applicable electronic communications regulations.

## ADDED Requirements

### Requirement: Privacy information is available

The application SHALL provide users with accessible information about cookies and similar technologies, personal-data processing, and privacy-related choices relevant to the application in both Polish and English.

#### Scenario: User looks for privacy information from login screen

- **WHEN** an unauthenticated user selects the privacy policy option on the login screen
- **THEN** the application opens a dialog with the privacy policy
- **AND** the policy describes data processing, storage technologies, data retention, legal bases, and user rights

#### Scenario: User looks for privacy information from Settings

- **WHEN** an authenticated user opens the Privacy section in Settings and selects the privacy policy action
- **THEN** the application opens a dialog with the privacy policy

### Requirement: Privacy choices are supported

The application SHALL provide an appropriate way for users to express and later review or change consent or privacy preferences where such choices apply.

#### Scenario: First visit consent notice

- **WHEN** a user accesses the application without prior saved consent preferences
- **THEN** the application displays a consent banner informing about essential storage and optional choices
- **AND** the user can choose to accept only necessary storage or all storage

#### Scenario: User reviews privacy choices in Settings

- **WHEN** a user accesses the Privacy section in Settings
- **THEN** the application presents the status of strictly necessary storage (always active)
- **AND** the user can review or change the preference for optional diagnostics or analytics
- **AND** the updated choice is immediately persisted to local storage

### Requirement: Privacy obligations are specified before implementation

Before implementing privacy notices or consent controls, the project SHALL specify the relevant data flows, user choices, and required behavior in this capability.

#### Scenario: Detailed privacy behavior is proposed

- **WHEN** implementation requirements for privacy information or consent are proposed
- **THEN** the specification describes the relevant data flows and user-facing behavior
- **AND** the requirements are reviewed against applicable obligations before implementation
