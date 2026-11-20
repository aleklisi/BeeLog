# Proposal

## Why

The current lists use separate up/down or left/right arrow controls to reorder items. Drag-and-drop is a more direct interaction for arranging cards and should be used consistently across apiaries, commercial hives, and mating hives.

## What Changes

- Remove the reorder arrow controls from the apiary list, commercial-apiary hive list, and mating-apiary hive list.
- Add drag-and-drop reordering for apiary cards in the type-specific apiary views.
- Add drag-and-drop reordering for commercial hive cards in the commercial-apiary view.
- Add drag-and-drop reordering for mating-hive cards in the mating-hive list view.
- Persist the resulting order and preserve it after navigation and reload.
- Keep item-specific actions such as edit, delete, move, and navigation independent from dragging a card.

## Capabilities

### New Capabilities

- `apiary-ordering`: Reorder apiaries with drag-and-drop in the apiary views.
- `commercial-hive-ordering`: Reorder commercial hives with drag-and-drop in a commercial-apiary view.
- `mating-hive-ordering`: Reorder mating hives with drag-and-drop in a mating-hive list view.

### Modified Capabilities

- None.

## Impact

- Affected Elm views: `Views.ApiaryList`, `Views.PasieczyskoTowarowe`, and `Views.Trutowisko`.
- Affected update and persistence logic in `frontend/src/Main.elm` and related model/decoder code for handling drag state and saved order values.
- Affected automated tests covering reordering and persistence.
- No external API or Firestore collection shape change is required if the existing order fields are retained.
