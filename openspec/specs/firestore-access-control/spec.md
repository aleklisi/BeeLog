# Firestore Access Control Specification

## Purpose

Defines owner-only access to BeeLog apiaries, hives, queen-rearing resources, and hive subcollection data stored in Firestore. Collaborator sharing is not supported.

## Requirements

### Requirement: Apiary data is restricted to its owner

Firestore access to an apiary and data associated with it SHALL be limited to its authenticated owner, identified by `adminId == request.auth.uid`.

#### Scenario: Owner accesses an apiary

- **WHEN** the authenticated owner reads or changes their apiary or its associated hive data
- **THEN** Firestore permits the operation

#### Scenario: Unrelated authenticated user accesses an apiary

- **WHEN** an authenticated user who does not own an apiary reads or changes it or its associated hive data
- **THEN** Firestore denies the operation

#### Scenario: Unauthenticated user accesses protected data

- **WHEN** a request without an authenticated Firebase user reads or changes apiary or hive data
- **THEN** Firestore denies the operation

### Requirement: Users can load only owned apiaries

The application SHALL load only apiaries owned by the authenticated user. It SHALL NOT read collaborator membership records or offer sharing controls.

#### Scenario: User loads their apiaries

- **WHEN** an authenticated user loads their apiary list
- **THEN** the application queries and returns only apiaries whose `adminId` matches that user's UID
- **AND** apiaries belonging to other users are not readable through the list query

### Requirement: Queen-rearing collections are restricted to their owner

Breeder queens, starter colonies, finisher colonies, and rearing batches SHALL be stored in top-level collections. Each document SHALL contain `userId` equal to the authenticated user's UID, and all reads and writes SHALL be restricted to that owner. Yearly sequence counters may remain under `users/{uid}/rearingSequences`.

#### Scenario: Owner accesses queen-rearing records

- **WHEN** an authenticated user queries or changes records whose `userId` matches their UID
- **THEN** Firestore permits the operation

#### Scenario: Another user accesses queen-rearing records

- **WHEN** an authenticated user reads or changes a record owned by another UID, or creates a record claiming another UID
- **THEN** Firestore denies the operation

### Requirement: Collaborator membership is unsupported

The application SHALL NOT create, read, update, or delete collaborator membership records. Firestore SHALL deny client access to the collaborators subcollection.

#### Scenario: Client attempts collaborator access

- **WHEN** an authenticated client reads or writes a collaborator record
- **THEN** Firestore denies the operation

### Requirement: Hive subcollections inherit apiary authorization

Notes and any other data nested under a hive SHALL enforce the same owner-only apiary access boundary as the parent hive.

#### Scenario: Owner accesses hive notes

- **WHEN** the apiary owner reads or changes notes under a hive belonging to that apiary
- **THEN** Firestore permits the operation

#### Scenario: Unauthorized user accesses hive notes

- **WHEN** a user who does not own the parent apiary reads or changes a hive subcollection
- **THEN** Firestore denies the operation

### Requirement: Access rules are verified by automated tests

The Firestore authorization requirements SHALL be covered by automated rules tests that exercise both permitted and denied requests.

#### Scenario: Rules test suite checks authorization boundaries

- **WHEN** the Firestore rules test suite runs against the configured emulator
- **THEN** it verifies owner access and denial for unauthenticated and unrelated authenticated users
- **AND** it verifies collaborator paths are denied and nested hive data is owner-only
