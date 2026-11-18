# Design: New Hive Types

## Context
Commercial hives currently support only `korpusowy` hives with identical korpuses. Beekeepers use different hive architectures (`ul korpusowy`, `ul leżak`, `ul kombinowany`). See proposal.md.

## Goals / Non-Goals
**Goals:**
- Support three hive types: `korpusowy`, `lezak`, `kombinowany`.
- Type-specific configuration for brood nest and supers (nadstawki) with frame types and counts.
- Elm UI and JSON decoders/encoders updated accordingly.

**Non-Goals:**
- Changing mating nucs (`uliki weselne`).

## Decisions
- Hive data structure in Elm will include `hiveType` (String or Union type, e.g., `"korpusowy"`, `"lezak"`, `"kombinowany"`), brood frame type & count, supers frame type & count (or list of supers/korpuses).
- For `korpusowy`, existing `korpusy` (list of korpus) is preserved for backwards compatibility.
- For `lezak` and `kombinowany`, store brood nest info (`broodFrameType`, `broodFrameCount`) and supers info (`superFrameType`, `superCount` or `superFrameCount`, etc.).

## Risks / Trade-offs
- Backward compatibility with existing Firestore hive documents that lack `hiveType`: default to `"korpusowy"`.
