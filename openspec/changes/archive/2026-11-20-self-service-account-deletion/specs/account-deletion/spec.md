# Spec Delta

## Purpose

Allow an authenticated BeeLog user to deliberately close their account and remove all application data associated with it, with clear confirmation and outcome feedback.

## ADDED Requirements

### Requirement: Account deletion is available in General Settings
The application SHALL provide an account deletion action in the General section of Settings.

#### Scenario: User opens account deletion confirmation
- **WHEN** an authenticated user chooses the account deletion action
- **THEN** the application shows a confirmation dialog with Cancel and Delete actions
- **AND** the dialog asks the user to type exactly `Tak, usuwam konto!`

### Requirement: Account deletion requires the exact confirmation phrase
The application SHALL start account deletion only when the user supplied the exact required phrase, including its punctuation and spacing.

#### Scenario: User submits an incorrect or empty phrase
- **WHEN** the user chooses Delete without entering the exact required phrase
- **THEN** the dialog shows a red error message that the phrase was entered incorrectly
- **AND** no account or application data is deleted

#### Scenario: User submits the exact phrase
- **WHEN** the user chooses Delete after entering exactly `Tak, usuwam konto!`
- **THEN** the application starts deleting that authenticated user's account and associated data

### Requirement: User can cancel account deletion
The application SHALL allow a user to close the confirmation dialog without deleting account or application data.

#### Scenario: User cancels deletion
- **WHEN** the user chooses Cancel
- **THEN** the dialog closes
- **AND** the account and its data remain available

### Requirement: Account deletion removes associated data
After a valid confirmation, the application SHALL delete the authenticated user's Firebase Authentication account and the BeeLog Firestore records currently associated with that account: the user profile and settings, queen-rearing records, owned apiaries, their hives, and hive notes. The application performs this cleanup with the Firebase client SDK and does not use Firebase Functions.

#### Scenario: User account and data are deleted
- **WHEN** the client-side deletion flow completes
- **THEN** the user's authentication account is deleted
- **AND** the user's profile and settings, queen-rearing records, owned apiaries, hives, and hive notes are deleted
- **AND** the application signs the user out and confirms completion

#### Scenario: Deletion encounters an error
- **WHEN** the client-side deletion flow cannot complete
- **THEN** the application reports that deletion failed without showing a success message
- **AND** the user can retry or close the dialog
