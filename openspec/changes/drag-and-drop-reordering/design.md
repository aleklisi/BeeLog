# Design

## Context

The three target views currently render cards from ordered model lists and expose arrow messages (`MoveApiaryUp/Down`, `MoveHiveUp/Down`, and `MoveUlikUp/Down`). The domain records already contain an integer `order` field, and the korpus editor demonstrates drag-and-drop reorder helpers in `Main.elm`.

## Goals / Non-Goals

**Goals:**

- Reuse one drag lifecycle for apiaries, commercial hives, and mating hives.
- Keep the existing integer order fields and persistence format.
- Make the drop target and resulting position deterministic for before/after placement.
- Prevent card navigation and action buttons from firing during a drag.
- Preserve hidden mating hives when the visible list is filtered.

**Non-Goals:**

- Changing the Firestore schema or moving records between apiaries.
- Reordering korpusy; that behavior is already implemented separately.
- Adding a new sorting mode, automatic sorting, or cross-apiary drag-and-drop.

## Decisions

### Use native HTML drag events in Elm

Cards will expose `draggable` and handle drag-start, drag-over, drag-end, and drop events with JSON decoders for the dragged record ID and drop zone. This matches the existing korpus drag implementation and avoids adding a dependency. A pointer-only custom gesture system was rejected because it would duplicate browser drag semantics and increase mobile/accessibility risk.

### Track the dragged entity explicitly

The model will track the active drag identity and entity kind, rather than relying on a view-local or list index. IDs remain stable when cards move, and the same update path can reject drops across incompatible collections or apiaries. Existing korpus drag state can remain compatible or be generalized as part of implementation.

### Reorder by stable IDs and normalize order values

On a valid drop, the update logic will remove the dragged record by ID, insert it before or after the target ID, and rewrite contiguous order values for the affected collection. This keeps ordering deterministic and avoids duplicate or stale order values after repeated moves. Record-specific fields remain untouched.

### Scope order updates to the owning collection

Apiary moves update the apiary list. Commercial hive moves update only the selected commercial apiary's hives. Mating-hive moves update only the selected mating apiary's uliki. When the mating list is filtered, the implementation will merge the reordered visible records back with hidden records while retaining hidden records' relative order.

### Keep action events distinct from drag events

The card-level drag handlers will stop propagation where needed and action controls will retain their existing event handlers. A completed drop updates order only; it does not navigate or open a modal. The visual affordance should identify the card as draggable without retaining arrow controls.

## Risks / Trade-offs

- [Risk] Native HTML drag behavior can be inconsistent on touch devices. → Keep the reorder operation usable at the card level and cover the supported browser behavior in E2E tests; do not introduce a new dependency without evidence that the existing approach is insufficient.
- [Risk] A filtered mating-hive list can accidentally overwrite hidden records. → Reorder by stable IDs and explicitly merge the visible subset into the full apiary collection before persisting.
- [Risk] Existing saved records may contain duplicate or missing order values. → Normalize order values after every reorder and use the current list order as the fallback input order during initial rendering.
- [Risk] Dragging over nested buttons may trigger a card click. → Separate drag completion from click handling and preserve stop-propagation behavior for action controls.

## Migration Plan

No data migration is required. Existing `order` values remain the persistence contract. During implementation, retain compatibility with records that lack a usable order by deriving their initial order from the current list position, then normalize values after the first successful reorder. Remove the obsolete arrow messages and controls after the drag handlers and tests are in place.
