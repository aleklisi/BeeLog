# Proposal

## Why

Users need a direct way to close their BeeLog account and remove the apiary and hive records tied to it. A typed confirmation reduces accidental, irreversible deletion.

## What Changes

- Add an account deletion action in the General section of Settings.
- Require users to type the exact phrase `Tak, usuwam konto!` in a confirmation dialog before enabling deletion.
- Delete the Firebase Authentication account and all Firestore documents and nested documents associated with that account.
- Report deletion errors without claiming success; provide a way to retry or leave the dialog.

## Capabilities

### New Capabilities

- `account-deletion`: User initiated, confirmed deletion of an account and its associated application data.

### Modified Capabilities

None.

## Impact

- General Settings UI and its Polish and English translations.
- Firebase Authentication and Firestore data deletion flows and rules.
- Use Firebase client SDK to remove known BeeLog collections; Firebase Auth may require a recent sign-in before deleting the account.
