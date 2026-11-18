# NFC and Data Schema

## Purpose
Manages NFC tag integration for direct hive access and defines the Firestore database schema structure.

## Requirements

### Requirement: NFC Tag Linking
Users SHALL be able to directly access specific hives via NFC scan.

#### Scenario: NFC Link Management
- **WHEN** viewing a hive or ulik
- **THEN** an NFC link field and a "copy NFC link" button MUST allow quick sharing and scanning to open the specific hive card directly.

### Requirement: Database Schema
The database SHALL follow a structured multi-root Firestore collection layout.

#### Scenario: Firestore Collections
- **WHEN** storing data in Firebase
- **THEN** collections MUST follow the schema: `/users/{userId}`, `/pasieczyska/{pasieczyskoId}/collaborators/{userId}`, and `/hives/{hiveId}`.
