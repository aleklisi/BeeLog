# Tasks

## 1. Data Model and Decoders

- [x] 1.1 Update `Hive` in `Types.Core.elm` with `maxBroodFrames`, `hasSuper`, `maxSuperFrames`, and `superFrameCount` fields
- [x] 1.2 Update JSON decoders in `Types.Decoders.elm` and persistence handling in `index.js`

## 2. Hive Creation Modal and UI Controls

- [x] 2.1 Update hive creation modal in `Main.elm` to support `maxBroodFrames`, `hasSuper`, `maxSuperFrames`, and `superFrameCount`
- [x] 2.2 Update `HiveDetail.elm` to provide "Dodaj nadstawkę" and "Zabierz nadstawkę" buttons for `kombinowany` hives
- [x] 2.3 Update `HiveDetail.elm` for `lezak` hives to display capacity settings and bounded frame adjustment controls (1..max) for brood and super

## 3. Testing and Verification

- [x] 3.1 Update unit tests in `ApiaryTest.elm` covering decoder and capacity rules
- [x] 3.2 Update and execute Playwright E2E tests verifying kombinowany buttons and lezak frame limits
