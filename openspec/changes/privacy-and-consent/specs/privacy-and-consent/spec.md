# privacy-and-consent Specification

## Purpose

Define the high-level user-facing privacy information and consent or preference capabilities BeeLog will provide. Detailed requirements are deferred until the application's data flows and applicable obligations are reviewed.

## ADDED Requirements

### Requirement: Privacy information is available

The application SHALL provide users with accessible information about cookies and similar technologies, personal-data processing, and privacy-related choices relevant to the application.

#### Scenario: User looks for privacy information

- **WHEN** a user accesses the application's privacy information
- **THEN** the application provides access to its cookie or similar-technology information and its personal-data privacy policy

### Requirement: Privacy choices are supported

The application SHALL provide an appropriate way for users to express and later review or change consent or privacy preferences where such choices apply.

#### Scenario: User reviews privacy choices

- **WHEN** a user accesses privacy or consent controls
- **THEN** the application presents the choices defined for the applicable technologies and processing purposes
- **AND** the user can review or change those choices

### Requirement: Privacy obligations are specified before implementation

Before implementing privacy notices or consent controls, the project SHALL specify the relevant data flows, user choices, and required behavior in this capability.

#### Scenario: Detailed privacy behavior is proposed

- **WHEN** implementation requirements for privacy information or consent are proposed
- **THEN** the specification describes the relevant data flows and user-facing behavior
- **AND** the requirements are reviewed against applicable obligations before implementation
