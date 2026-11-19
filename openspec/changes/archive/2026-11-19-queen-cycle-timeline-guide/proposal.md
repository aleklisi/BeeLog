# Proposal

## Why

The mating-hive timeline already uses colored periods, but users have no in-view explanation of what each color means for the queen's expected state. A compact legend will make the timeline actionable and clarify when a queen is expected to be mated or overdue.

## What Changes

- Add an accessible information control beside the mating-hive cycle timeline title.
- Reveal a color legend describing expected queen status for each timeline period.
- Preserve the existing timeline dates, period boundaries, and attention behavior.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `mating-apiaries`: Explain the timeline's color-coded queen cycle and provide an in-context legend.

## Impact

- `frontend/src/Views/Trutowisko.elm`: mating-hive list timeline presentation.
- OpenSpec mating-apiaries delta specification.
