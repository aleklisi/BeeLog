# Proposal: Hive Types Refinements

## Why
Beekeepers managing `lezak` (long hives) and `kombinowany` (combined hives) need precise control over the capacity limits and current operational state of frames and supers:
- For `lezak`, beekeepers need to define maximum brood frame capacity, toggle whether a super is mounted, define maximum super frame capacity when present, and independently adjust the active number of brood frames and super frames within their respective 1..max bounds.
- For `kombinowany`, beekeepers need dedicated action buttons ("Dodaj nadstawkę", "Zabierz nadstawkę") to quickly increment or decrement the count of supers.

## What Changes
- Add dedicated buttons "Dodaj nadstawkę" and "Zabierz nadstawkę" in `kombinowany` hives with minimum bound 0.
- For `lezak` hives:
  - Add configuration for maximum brood frames (`maxBroodFrames`) and enforce 1..max bounds for active brood frames (`broodFrameCount`).
  - Add checkbox / toggle whether a super is present (`hasSuper`).
  - When `hasSuper` is true, add configuration for maximum super frames (`maxSuperFrames`) and enforce 1..max bounds for active super frames (`superFrameCount`).
  - Add intuitive frame increment/decrement adjustment controls for brood frames and super frames.
- Update Elm core types, decoders, create hive modal, and detail view.
- Update unit tests and Playwright E2E scenarios.

## Capabilities

### Modified Capabilities
- `hives`: Advanced capacity configuration and frame/super adjustment controls for `lezak` and `kombinowany` hives.

## Impact
Elm types, JSON decoders, UI controls in `HiveDetail.elm` and modal in `Main.elm`, persistence in `index.js`, and tests.
