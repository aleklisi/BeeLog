# Tasks

## 1. Firestore Rules Test Harness

- [ ] 1.1 Add `@firebase/rules-unit-testing` and a reproducible Firebase CLI dependency, then add a Firestore rules test script; verify dependency installation with `npm ci` and that the script is discoverable.
- [ ] 1.2 Add emulator fixtures for apiary owners, `edit` and `view` collaborators, unrelated users, unauthenticated requests, hives, and nested notes; verify fixture setup runs with the Firestore Emulator.
- [ ] 1.3 Add baseline allow/deny rules tests for apiary reads and writes, collaborator management, hive moves, and nested hive data; run the suite against the current rules and verify it demonstrates the current cross-user access defect.

## 2. Membership Identity and Apiary Queries

- [ ] 2.1 Define and implement verified-email collaborator identity normalization for existing and newly shared apiaries; verify owners can still share with an email and an unrelated or unverified account cannot claim access.
- [ ] 2.2 Update apiary list loading to query only owned apiaries and apiaries with a matching collaborator grant; verify owner and collaborator lists load while other apiaries are not returned.
- [ ] 2.3 Enforce the `edit` and `view` role behavior in application operations and membership management; verify view collaborators can read but cannot write, and only owners can grant or revoke membership.

## 3. Firestore Authorization Rules

- [ ] 3.1 Restrict apiary read, update, and delete operations to the owner and authorized collaborators, with delete and membership management reserved for the owner; verify the corresponding owner/editor/viewer and denial tests pass.
- [ ] 3.2 Restrict hive create, read, update, delete, and move operations through the parent apiary, requiring edit access to both source and destination apiaries for a move; verify cross-apiary attempts are denied.
- [ ] 3.3 Restrict notes and all other hive subcollections using the parent hive's apiary authorization; verify authorized access succeeds and cross-user access is denied.
- [ ] 3.4 Run the complete Firestore rules suite with `firebase emulators:exec --only firestore "npm run test:rules"` and verify every allow and deny case passes.

## 4. CI and Deployment Verification

- [ ] 4.1 Add the Firestore rules suite to `make all_test` and CI using the Firebase Emulator; verify CI runs the rules suite on pushes and pull requests.
- [ ] 4.2 Verify owner, editor, viewer, invitation, apiary-list, hive, and note workflows in the emulator and run `make all_test` successfully before deploying restrictive rules.
