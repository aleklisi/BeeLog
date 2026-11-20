# Proposal

## Why

Apiary sharing adds slow, sequential collaborator reads and a permission model the product no longer needs. Firestore rules currently grant every authenticated user read and write access to all apiaries and hives, so removing sharing must also enforce ownership at the database boundary.

## What Changes

- Remove apiary invitations, collaborator management, roles, and collaborator records from the application.
- Restrict reads and writes for apiaries, hives, notes, and other nested hive data to the authenticated owner of the parent apiary.
- Deny access to unauthenticated users and authenticated users without access to the specific apiary.
- Add automated Firestore Security Rules tests for allowed and denied access paths, including cross-apiary and collaborator-management attempts.
- Load only apiaries owned by the signed-in user.

## Capabilities

### New Capabilities

- `firestore-access-control`: Authorization boundaries for Firestore apiary and hive data.

### Modified Capabilities

None.

## Impact

- `firestore.rules` and the Firestore emulator configuration.
- Apiary and hive data access in `frontend/src/index.js`, especially collaborator identity and role handling.
- Automated rules tests, likely using `@firebase/rules-unit-testing` with the Firebase Emulator Suite.
- Existing collaborator documents are ignored and grant no access.
