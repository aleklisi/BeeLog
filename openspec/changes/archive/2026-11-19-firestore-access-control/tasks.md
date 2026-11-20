# Tasks

## 1. Owner-only application access

- [x] 1.1 Remove apiary sharing UI, view state, Elm messages and model fields, translations, and JavaScript ports/handlers.
- [x] 1.2 Load only apiaries owned by the signed-in user and remove all collaborator reads and writes.
- [x] 1.3 Update decoders, unit tests, and end-to-end fixtures to remove collaborator membership data.

## 2. Firestore authorization

- [x] 2.1 Restrict apiary read, create, update, and delete operations to the authenticated owner; deny collaborator subcollection access.
- [x] 2.2 Restrict hive operations through the owner of the parent apiary, including moves between owned apiaries.
- [x] 2.3 Restrict notes and all hive subcollections using the parent apiary owner authorization.
- [ ] 2.4 Add or update automated Firestore rules tests for owner access and denied unrelated/unauthenticated access; verify via the project Make target.

## 3. Documentation and verification

- [x] 3.1 Update the main OpenSpec data schema and product documentation to remove sharing.
- [x] 3.2 Run focused Elm and end-to-end tests through Make and verify the application builds.
