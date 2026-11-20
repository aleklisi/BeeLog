# Proposal: Navigation and Voice Fixes

## Why
Bug fixes are needed for back button navigation when moving hives/uliks between apiaries or accessing via NFC tag, and voice dictation in commercial hives is currently not working.

## What Changes
- Fix back button navigation to return to the current apiary where the hive/ulik is located rather than the origin apiary.
- Fix voice note dictation in commercial hives.

## Capabilities

### Modified Capabilities
- `hives`: Voice dictation fix.
- `mating-apiaries`: Correct back button navigation on relocation/NFC access.

## Impact
Router / navigation state in Elm and Web Speech API usage for voice notes.
