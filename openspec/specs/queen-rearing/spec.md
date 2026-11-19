# Queen Rearing Specification

## Purpose

Defines how users manage queen-rearing resources and batches from grafting through emergence, including resource availability, schedule dates, and operational alerts.

## Requirements

### Requirement: Configure queen-rearing defaults
Users SHALL be able to configure the default graft count and day offsets for the queen-rearing schedule. The application SHALL reject values outside the stated ranges and SHALL use the defaults for newly started batches.

#### Scenario: Provide default queen-rearing settings
- **WHEN** the queen-rearing settings have not been configured
- **THEN** the default graft count is 24, starter duration is 2 days, isolation is day 10, and expected emergence is day 11

#### Scenario: Validate schedule settings
- **WHEN** a user saves schedule settings
- **THEN** graft count must be a positive integer, starter duration must be 1 through 10 days, isolation must be later than the starter transfer, and emergence must be on or after isolation

### Requirement: Manage queen-rearing resources
Users SHALL be able to create, edit, and view breeder queens, starter colonies, and finisher colonies. Breeder queens SHALL record breed and line, marking color and code, and hive number. Starter and finisher colonies SHALL record hive number, availability (`PUSTY` or `ZAJETY`), and a completed-series counter defaulting to zero. A resource assigned to an active batch SHALL NOT be deleted, and inactive breeder queens SHALL NOT be offered for new batches.

#### Scenario: View and manage resources
- **WHEN** a user opens queen-rearing resources
- **THEN** the user can view breeder queens, starters, and finishers with their identifying details and availability

#### Scenario: Prevent deleting an assigned colony
- **GIVEN** a starter or finisher is assigned to an active batch
- **WHEN** a user attempts to delete that colony
- **THEN** the deletion is rejected and the active batch remains unchanged

#### Scenario: Deactivate a breeder queen referenced by a batch
- **GIVEN** a breeder queen is referenced by a batch
- **WHEN** a user wants to retire that breeder queen
- **THEN** the queen can be marked inactive, cannot be deleted, and is unavailable for new batches

### Requirement: Create and start a rearing batch
A user SHALL be able to create a uniquely numbered planned batch and start it with a breeder queen, a free starter, a positive graft count, a graft date and time, and the user's IANA time zone. The batch SHALL retain the schedule durations used when it starts. Its number SHALL be assigned atomically, be unique to that user and calendar year, and never be reused after deletion.

#### Scenario: Create a planned batch
- **WHEN** a user creates a rearing batch
- **THEN** it receives the next unused number in `YYYY/NN` format for that user and calendar year and has status `ZAPLANOWANA`

#### Scenario: Start a batch and calculate its schedule
- **GIVEN** the user has configured 2 starter days, 10 days to isolation, and 11 days to emergence
- **WHEN** the user starts a batch at 2026-05-10 10:00 in `Europe/Warsaw`
- **THEN** the batch enters `W_STARTERZE`, reserves the selected free starter, and calculates dates of 2026-05-12 10:00, 2026-05-20 10:00, and 2026-05-21 10:00 in that time zone

#### Scenario: Preserve the batch schedule after settings change
- **GIVEN** a batch has started with saved schedule durations
- **WHEN** the user changes the default durations in settings
- **THEN** the existing batch dates remain unchanged and newly started batches use the new defaults
- **AND** adding schedule days preserves the local start time in the batch's saved time zone

### Requirement: Reserve and release colonies exclusively
An active batch SHALL exclusively reserve its assigned starter or finisher. Reservation, status transition, and batch update SHALL succeed or fail together, including when users act concurrently. Resources SHALL be released when their stage ends; their counters increase only after normal stage completion and not when an active batch is deleted.

#### Scenario: Reject a colony already reserved by another batch
- **GIVEN** another active batch has reserved starter `S-1`
- **WHEN** a user attempts to start a batch using `S-1`
- **THEN** the action is rejected and no batch or colony state is partially updated

#### Scenario: Move an accepted batch to a finisher
- **GIVEN** a batch is in `W_STARTERZE` and has at least one accepted cell
- **WHEN** the user selects a free finisher
- **THEN** the batch enters `W_FINISHERZE`, the starter is released and its series counter increases by one, and the finisher is reserved

#### Scenario: Release resources when deleting an active batch
- **GIVEN** a batch in `W_STARTERZE` or `W_FINISHERZE` is deleted
- **WHEN** the deletion completes
- **THEN** its assigned colony is released and its completed-series counter remains unchanged

### Requirement: Progress and complete a rearing batch
Users SHALL progress batches through `ZAPLANOWANA`, `W_STARTERZE`, `W_FINISHERZE`, `W_CIEPLARCE`, and `ZAKONCZONA` in order, with a direct completion path from finisher to completed. Counts SHALL be whole numbers within the batch's recorded counts.

#### Scenario: Reject invalid count values
- **GIVEN** a batch has 24 grafted larvae
- **WHEN** the user enters a negative count, a fractional count, or more accepted cells than grafted larvae
- **THEN** the transition is rejected and the batch and colony states remain unchanged

#### Scenario: End a batch with no accepted cells
- **GIVEN** a batch is in `W_STARTERZE`
- **WHEN** the user records zero accepted cells and ends the batch
- **THEN** the batch enters `ZAKONCZONA`, the starter is released and its counter increases by one, and no finisher is assigned

#### Scenario: Move a batch into an incubator
- **GIVEN** a batch is in `W_FINISHERZE` and has accepted cells
- **WHEN** the user enters an incubator bar number and moves the batch to the incubator
- **THEN** the batch enters `W_CIEPLARCE` and the finisher is released with its counter increased by one

#### Scenario: Complete a batch after emergence
- **GIVEN** a batch is in `W_CIEPLARCE`
- **WHEN** the user records an emerged queen count from zero through the accepted cell count
- **THEN** the batch enters `ZAKONCZONA` and retains the emergence count and incubator bar number

#### Scenario: Complete a batch directly from a finisher
- **GIVEN** a batch is in `W_FINISHERZE`
- **WHEN** the user records an emerged queen count and completes the batch without an incubator
- **THEN** the batch enters `ZAKONCZONA`, the finisher is released with its counter increased by one, and the incubator bar number remains empty

### Requirement: Prioritize batches by next action
The batch list SHALL show the next action date for active batches and sort overdue batches first, then upcoming active batches by nearest deadline, then planned batches, then completed batches. For equal priority, batches SHALL sort by next-action date and then by batch number.

#### Scenario: Show the next action and urgency
- **GIVEN** batches are in starter, finisher, and incubator states
- **WHEN** the user views the batch list
- **THEN** their next actions are based on transfer-to-finisher, isolation, and emergence dates respectively, with overdue alerts red, deadlines within 24 hours yellow, and later deadlines green

#### Scenario: Sort batches by urgency
- **GIVEN** one active batch is overdue, two active batches have future deadlines, and one batch is planned
- **WHEN** the user views the batch list
- **THEN** the overdue batch appears first, future deadlines are ordered nearest-first, and the planned batch appears after active batches

#### Scenario: Format time remaining
- **WHEN** an active batch has a next-action deadline
- **THEN** remaining time below 24 hours is shown in hours, otherwise remaining days are rounded up, and a deadline exactly now is marked urgent

### Requirement: Inspect and edit batch details
Selecting a batch SHALL open a detail view showing its breeder, starter, finisher, incubator bar when present, counts, status, and schedule dates. The view SHALL offer only actions valid for the current status, allow editing saved details subject to the same validation rules, and allow deletion with the required release of active resources.

#### Scenario: Review batch details
- **WHEN** a user opens a batch
- **THEN** all resource assignments, counts, dates, and valid next actions are visible
