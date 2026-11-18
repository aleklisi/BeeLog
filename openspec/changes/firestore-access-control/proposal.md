# Proposal

## Why

Firestore rules currently grant every authenticated user read and write access to all apiaries, hives, and apiary collaborator records. This bypasses the ownership and collaboration boundaries the application presents to users and can expose or allow modification of another user's apiary data.

## What Changes

- Restrict reads and writes for apiaries, hives, notes, and other nested hive data to the apiary owner or an explicitly authorized collaborator.
- Restrict collaborator membership changes to the apiary owner and validate the identity and role being granted.
- Deny access to unauthenticated users and authenticated users without access to the specific apiary.
- Add automated Firestore Security Rules tests for allowed and denied access paths, including cross-apiary and collaborator-management attempts.
- Reconcile the current collaborator records keyed by email with rules that need a trustworthy authenticated user identity.

## Capabilities

### New Capabilities

- `firestore-access-control`: Authorization boundaries for Firestore apiary and hive data.

### Modified Capabilities

None.

## Impact

- `firestore.rules` and the Firestore emulator configuration.
- Apiary and hive data access in `frontend/src/index.js`, especially collaborator identity and role handling.
- Automated rules tests, likely using `@firebase/rules-unit-testing` with the Firebase Emulator Suite.
- Existing data may need a migration if collaborator membership must be keyed by Firebase Auth UID rather than email.
