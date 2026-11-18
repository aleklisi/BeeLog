# Spec Delta

## Purpose

Defines who may read or change BeeLog apiaries, hives, collaborator membership, and hive subcollection data stored in Firestore. Access is granted only to authenticated users authorized for the particular apiary.

## ADDED Requirements

### Requirement: Apiary data is restricted to its owner and collaborators

Firestore access to an apiary and data associated with it SHALL be limited to its owner and users explicitly authorized as collaborators for that apiary.

#### Scenario: Owner accesses an apiary

- **WHEN** the authenticated owner reads or changes their apiary or its associated hive data
- **THEN** Firestore permits the operation according to the owner's privileges

#### Scenario: Authorized collaborator accesses an apiary

- **WHEN** an authenticated user with an active collaborator grant accesses an apiary or its associated hive data
- **THEN** Firestore permits only the operations allowed by that collaborator's assigned role

#### Scenario: Unrelated authenticated user accesses an apiary

- **WHEN** an authenticated user without ownership or an active collaborator grant reads or changes an apiary or associated hive data
- **THEN** Firestore denies the operation

#### Scenario: Unauthenticated user accesses protected data

- **WHEN** a request without an authenticated Firebase user reads or changes apiary or hive data
- **THEN** Firestore denies the operation

### Requirement: Users can load only apiaries they may access

The application SHALL let an authenticated user load their owned and shared apiaries while Firestore denies list queries that could return apiaries outside that user's access.

#### Scenario: User loads accessible apiaries

- **WHEN** an authenticated user loads their apiary list
- **THEN** the application returns the apiaries they own or have an active collaborator grant for
- **AND** apiaries belonging only to other users are not readable through the list query

### Requirement: Collaborator membership changes are owner-controlled

Only the apiary owner SHALL grant or revoke collaborator access, and membership records SHALL identify an authenticated account unambiguously.

#### Scenario: Owner changes collaborator membership

- **WHEN** the apiary owner grants or revokes a collaborator's access
- **THEN** Firestore permits the membership change if the new membership data is valid

#### Scenario: Non-owner changes collaborator membership

- **WHEN** a collaborator or another authenticated user attempts to grant, change, or revoke membership
- **THEN** Firestore denies the operation

#### Scenario: User forges collaborator identity or role

- **WHEN** a user attempts to write a membership record for a different authenticated identity or to assign a role they are not authorized to grant
- **THEN** Firestore denies the operation

### Requirement: Hive subcollections inherit apiary authorization

Notes and any other data nested under a hive SHALL enforce the same apiary access boundary as the parent hive.

#### Scenario: Authorized user accesses hive notes

- **WHEN** the apiary owner or a collaborator with the required permission reads or changes notes under a hive belonging to that apiary
- **THEN** Firestore permits the operation according to that user's role

#### Scenario: Unauthorized user accesses hive notes

- **WHEN** a user without permission for the parent apiary reads or changes a hive subcollection
- **THEN** Firestore denies the operation

### Requirement: Access rules are verified by automated tests

The Firestore authorization requirements SHALL be covered by automated rules tests that exercise both permitted and denied requests.

#### Scenario: Rules test suite checks authorization boundaries

- **WHEN** the Firestore rules test suite runs against the configured emulator
- **THEN** it verifies owner and authorized collaborator access
- **AND** it verifies denial for unauthenticated and unrelated authenticated users
- **AND** it verifies collaborator-management and nested hive-data restrictions
