# Tasks

## 1. Client SDK foundation

- [x] 1.1 Remove the callable function, Admin SDK package, Firebase Functions configuration, and Functions emulator.

## 2. Client-side deletion

- [x] 2.1 Remove the caller's profile and known queen-rearing collections, owned apiaries, their hives and notes, then delete the Firebase Authentication account last.
- [x] 2.2 Keep partial cleanup retryable, handle recent-login errors, and report failure without showing success.

## 3. Settings confirmation flow

- [x] 3.1 Add an account deletion action to General Settings and a dialog with the exact phrase, Cancel and Delete controls.
- [x] 3.2 Validate the phrase in the client, display the red error on empty or incorrect input, prevent duplicate submissions while deleting, and present retryable errors or success.

## 4. End-to-end integration

- [ ] 4.1 Connect the dialog to client-side cleanup, sign the user out after success, and verify the complete flow with emulator data plus a production build using `npm run build`.

