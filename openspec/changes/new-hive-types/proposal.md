# Proposal: New Hive Types

## Why
Users need more flexibility in commercial hive management by supporting different beekeeping architectures (korpusowy, lezak, kombinowany) rather than only multi-korpus hives.

## What Changes
- Rename current hive type to "ul korpusowy" (where all korpuses are identical size).
- Add "ul lezak" (has a brood nest with specified frame type and count, and an optional supers/nadstawka with specified frame type and count).
- Add "ul kombinowany" (similar to lezak, but supporting 0 or more supers).
- Update hive creation and editing UI to select hive type first and then configure type-specific parameters.

## Capabilities

### Modified Capabilities
- `hives`: Support for multiple hive types (korpusowy, lezak, kombinowany) and type-specific configurations.

## Impact
Commercial hive data structures, UI forms in Elm, and Firestore persistence.
