# Mating Apiaries

## Purpose
Manages mating apiaries (trutowiska) and mating hives (uliki weselne), their lifecycle states, timelines, tracking, and history.

## Requirements

### Requirement: Mating Hive States and Lifecycle
Mating hives SHALL track queen development states and support transitions.

#### Scenario: State Transitions and Automation
- **WHEN** a mating hive transitions through states: Empty `(P)`, Bezmatek `(B)`, Z matecznikiem `(M)`, Matka wygryziona `(N)`, and Matka unasienniona `(UNC)`
- **THEN** the system MUST prompt for required details (expected hatching date, breed/line, optional queen marking/opalitkowanie with color and number), automatically calculate expected mating date using configuration settings, and record state changes in a history log.

### Requirement: Timeline and History
The system MUST visualize time progression and maintain historical state changes for mating hives.

#### Scenario: Timeline Axis and History Log
- **WHEN** viewing a mating hive
- **THEN** an interactive timeline axis MUST highlight key periods (now to hatching, hatching to mating, and post-mating danger zone) in distinct colors, and a timestamped history log MUST display state transitions sorted from newest to oldest up to the configured maximum history limit.

#### Scenario: Timeline color legend explains expected queen status
- **WHEN** a user views the mating-hive list timeline and opens its information control
- **THEN** a legend MUST explain that the pre-hatching yellow period means a queen is expected to emerge, the hatching-to-expected-mating yellow period means she is expected to mature and mate, the green period means she should already be mated, and the red period means mating has been overdue beyond the 30-day post-hatching deadline.

#### Scenario: Timeline information is available without opening the legend
- **WHEN** a user views the mating-hive list timeline
- **THEN** an information control labelled for assistive technology MUST be visible beside its heading and MUST reveal or hide the color legend when activated.

### Requirement: Moving Mating Hives
Users SHALL be able to relocate mating hives between mating apiaries.

#### Scenario: Relocation and Back Navigation
- **WHEN** a mating hive is moved from Mating Apiary A to Mating Apiary B
- **THEN** it MUST be reassigned to Apiary B and the back button navigation MUST correctly return to the current apiary view.

### Requirement: Korpusowy Mating Hives
Mating hives SHALL support marking a mating hive as korpusowy and tracking its number of korpusy.

#### Scenario: Configure Korpusowy Status and Count
- **WHEN** a user creates or edits a mating hive
- **THEN** they MUST be able to toggle whether the hive is korpusowy and configure its number of korpusy.
- **AND** when the hive is korpusowy, it MUST have at least one korpus and its current korpus count MUST be visible in the hive details, similarly to frame counts for leżak hives.
- **AND** a mating hive of type "Mini plus" MUST default to korpusowy.
