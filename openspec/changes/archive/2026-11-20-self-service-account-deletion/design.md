# Design

## Context

BeeLog uses Firebase Authentication and Firestore. User preferences and queen-rearing data are stored under `users/{uid}`; apiaries are in the top-level `pasieczyska` collection and identify their owner with `adminId`; hives are in the top-level `hives` collection and identify their apiary with `apiaryId`; notes are nested under hive documents. Account deletion runs in the browser with the Firebase client SDK and must not use Firebase Functions.

## Goals / Non-Goals

**Goals:**

- Require the exact confirmation phrase in the client.
- Remove the caller's records in known BeeLog collections before deleting the Authentication account.
- Make cleanup retryable after partial failures and report success only after all deletion steps finish.

**Non-Goals:**

- Retain or export account data after deletion.
- Delete records owned by a different account or support transferring apiaries to another user.

## Decisions

- Use Firebase client SDK queries to find apiaries by `adminId` and their hives by `apiaryId`; explicitly delete each hive's `notes` and the known user subcollections (`breederQueens`, `starterColonies`, `finisherColonies`, `rearingBatches`, `rearingSequences`) before deleting parent documents.
- Delete the Firebase Authentication user only after Firestore cleanup completes. Repeating the request after a partial Firestore failure is safe because missing records are treated as already deleted; the Authentication account remains available until the final step.
- The browser SDK cannot discover arbitrary subcollections, so extend the deletion list whenever BeeLog adds a collection. Firebase Auth may require a recent sign-in; show that as a retryable error.
- Keep the dialog open while the operation runs, prevent duplicate submissions, then sign the client out after success. On failure, show an error and keep retry/cancel available.
- Exercise the deletion flow against the Auth and Firestore emulators without configuring a Functions emulator.

## Risks / Trade-offs

- [Recursive deletion spans multiple Firestore documents and is not atomic] → Make the function idempotent, delete Authentication last, and allow retry while the account still exists.
- [A user may own many records] → Delete matching records in the client before reporting success; keep errors retryable.
- [Auth may reject deletion when the sign-in is not recent] → Keep the account deletion dialog open and ask the user to sign in again before retrying.

## Migration Plan

1. Implement and exercise client-side deletion against emulator data.
2. Release the frontend without deploying Firebase Functions.
3. Roll back by reverting the frontend; already deleted records and accounts cannot be restored by rollback.
