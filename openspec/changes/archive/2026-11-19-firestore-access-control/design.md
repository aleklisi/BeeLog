# Design

## Context

See proposal.md - Why. Firestore currently grants access based only on `request.auth != null`. Apiaries store `adminId`; collaborators are no longer a product concept. Hives are top-level documents linked to apiaries by `apiaryId`, with notes and other records in subcollections. The client must query only apiaries owned by the signed-in user, and rules must authorize related documents through their parent apiary.

## Goals / Non-Goals

**Goals:**
- Enforce owner-only access in Firestore rules for apiaries, hives, and hive subcollections.
- Remove collaborator UI, state, ports, and Firestore reads/writes.
- Load only owned apiaries through queries compatible with Firestore Security Rules.
- Test authorization behavior against the Firestore Emulator.

**Non-Goals:**
- Redesign the Firebase API key or treat the client Firebase config as an authorization mechanism.
- Add a server-side authorization service or Cloud Functions deployment.
- Change access to user settings outside the existing per-user document rules.

## Decisions

1. **Use the apiary owner as the sole principal.** Apiary reads and writes require `adminId == request.auth.uid`. Existing collaborator subcollection documents do not grant access and are not read by the app.

2. **Authorize child data through the parent apiary.** Hive creates require an owned destination apiary. Hive reads and deletes require ownership of their current apiary. Updates require ownership of both the existing and resulting apiary, so moving a hive requires ownership of both. Hive subcollections resolve the parent hive and enforce the same owner check.

3. **Query only owned apiaries.** `jsLoadApiaries` filters at Firestore with `where("adminId", "==", uid)`, then loads each apiary's hives. It performs no collaborator reads.

4. **Use Firestore Emulator rules tests as the security acceptance suite.** Test owner, unrelated authenticated user, and unauthenticated user access, including hive moves and nested data. Seed fixtures with rules disabled, then assert allowed and denied operations.

## Risks / Trade-offs

- [Existing collaborator documents remain in Firestore] → Ignore them in application code and deny access to the collaborators subcollection; they can be removed separately if desired.
- [Rules updates can deny legitimate operations if a path is missed] → Cover all port-driven CRUD paths, hive moves, notes, and nested subcollections with emulator tests before deployment.
- [Rules may require document lookups and consume Firestore rule access calls] → Keep helper lookups bounded and exercise multi-write operations in tests.

## Migration Plan

1. Remove application sharing and update apiary list queries to select only owner records.
2. Seed and run emulator rules tests against the candidate rules for owners and denied users.
3. Deploy restrictive rules after the automated suite passes, then verify owner workflows against the deployed project.
4. If legitimate access fails, restore the previous rules temporarily, inspect denied operations, and correct the candidate rules before redeploying. Do not restore broad authenticated-user access as a permanent fix.
