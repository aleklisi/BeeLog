# Design: Hive Types Refinements

## Context
Commercial hives support `korpusowy`, `lezak`, and `kombinowany`. See proposal.md for motivation and user requirements regarding maximum capacity and frame/super adjustment controls.

## Goals / Non-Goals

**Goals:**
- Provide buttons ("Dodaj nadstawkę", "Zabierz nadstawkę") for `kombinowany` hives.
- Add maximum frame capacity configuration (`maxBroodFrames`, `maxSuperFrames`) for `lezak` hives.
- Add `hasSuper` checkbox toggle for `lezak` hives.
- Add granular controls to adjust active frames in brood nest and super for `lezak` hives constrained within 1..max.
- Ensure backwards compatibility in Elm decoders and persistence.

**Non-Goals:**
- Altering the multi-korpus editor of `korpusowy` hives.
- Changes to mating hives (`uliki weselne`).

## Decisions

- **Decision 1: Extended Hive data model**
  Extend `Hive` in `Types.Core.elm`:
  - `maxBroodFrames : Int` (default 24)
  - `hasSuper : Bool` (default False)
  - `maxSuperFrames : Int` (default 18)
  - `superFrameCount : Int` (default 10)
  Resilient decoders in `Types.Decoders.elm` will handle existing documents gracefully.

- **Decision 2: UI Controls in HiveDetail.elm**
  - In `kombinowany`: Dedicated "Dodaj nadstawkę" and "Zabierz nadstawkę" buttons that update `superCount` (min: 0).
  - In `lezak`:
    - Technical specs section contains `maxBroodFrames` input, `hasSuper` checkbox, and (when `hasSuper` is true) `maxSuperFrames`.
    - Nest & Supers section contains `-` and `+` adjustment controls for `broodFrameCount` (bounded `1..maxBroodFrames`) and for `superFrameCount` (bounded `1..maxSuperFrames` when `hasSuper`).

- **Decision 3: Hive Creation Modal in Main.elm**
  Include the new configuration fields conditionally based on selected `hiveType` with validation preventing out-of-bounds frame counts.

## Risks / Trade-offs

- *[Risk]* Legacy hive documents lack `maxBroodFrames` or `hasSuper`.
  *Mitigation*: Provide sensible defaults in `Types.Decoders.elm` (`maxBroodFrames = max 10 broodFrameCount`, `hasSuper = superCount > 0`, `maxSuperFrames = 18`, `superFrameCount = 10`).
