# Design

## Context

See proposal.md - Why. Firestore currently grants access based only on `request.auth != null`. Apiaries store `adminId`; collaborator documents are currently keyed inconsistently by owner UID or invitee email and contain a `role` (`edit` or `view`). Hives are top-level documents linked to apiaries by `apiaryId`, with notes and other records in subcollections. `jsLoadApiaries` currently reads every apiary and filters access in the browser, which Firestore rules cannot safely support once data-level access is restricted.

## Goals / Non-Goals

**Goals:**
- Enforce ownership and collaborator access in Firestore rules for apiaries, hives, and hive subcollections.
- Preserve the existing owner, editor, and viewer product model while making membership identity verifiable.
- Load only owned or shared apiaries through queries compatible with Firestore Security Rules.
- Test authorization behavior against the Firestore Emulator.

**Non-Goals:**
- Redesign the Firebase API key or treat the client Firebase config as an authorization mechanism.
- Add a server-side authorization service or Cloud Functions deployment.
- Change access to user settings outside the existing per-user document rules.

## Decisions

1. **Keep email invitations, but bind them to verified Firebase Auth email claims.** Normalize invited email addresses and store the invitee email as an explicit membership field. Rules grant collaborator access only when the authenticated token has a verified email matching that field. Owner access continues to use `adminId == request.auth.uid`. This avoids adding a server-side identity lookup service and prevents an unverified account from claiming an invitation. An alternative is a server-mediated UID invitation flow; it is deferred because this project has no backend functions deployment.

2. **Enforce roles in rules, not only in the UI.** Owners may manage apiary membership and delete their apiary. `edit` collaborators may read and change apiary and hive data but may not change membership. `view` collaborators may read data and may not write it. Reject unknown roles and constrain membership fields to the expected schema. The UI's selected role is untrusted input.

3. **Authorize hives through their parent apiary.** Hive creation must name an apiary the user can edit. Hive updates must authorize the current and resulting `apiaryId`, so moving a hive requires edit access to both apiaries. Hive subcollections resolve the parent hive and enforce its apiary's access policy. Apiary list loading must query owned apiaries and matching collaborator memberships, then fetch only those parent apiaries; it must not list the whole collection and filter results client-side.

4. **Use Firestore Emulator rules tests as the security acceptance suite.** Add `@firebase/rules-unit-testing` tests with authenticated contexts for owner, editor, viewer, unrelated user, and unauthenticated user. Seed fixtures with rules disabled, then assert both allowed and denied operations. Run them through the existing Firebase Emulator Suite using a dedicated script/Make target and in CI.

## Risks / Trade-offs

- [Existing collaborator documents use inconsistent IDs and may not include a verified email field] → Add an explicit migration/normalization step and test existing owner and collaborator scenarios before deploying restrictive rules.
- [Email/password accounts may not currently verify their email] → Add or enforce email verification before granting access through email invitations; Google sign-in accounts use their verified token claim.
- [Firestore rules are not query filters] → Change apiary loading to query owner records and matching membership records before enabling the restrictive rules; test these production-shaped queries in the emulator.
- [Rules updates can deny legitimate operations if a path is missed] → Cover all port-driven CRUD paths, hive moves, notes, and nested subcollections with emulator tests before deployment.
- [Rules may require document lookups and consume Firestore rule access calls] → Keep helper lookups bounded and exercise multi-write operations in tests.

## Migration Plan

1. Implement the identity and membership normalization path and update apiary list queries while the current permissive rules remain in place.
2. Seed and run emulator rules tests against the candidate rules, including existing owner and collaborator fixtures.
3. Deploy restrictive rules after the automated suite passes, then verify owner/editor/viewer workflows against the deployed project.
4. If legitimate access fails, restore the previous rules temporarily, inspect denied operations, and correct the candidate rules before redeploying. Do not restore broad authenticated-user access as a permanent fix.
