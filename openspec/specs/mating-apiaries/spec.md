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

### Requirement: Identify mating hives requiring attention
The mating-apiary hive list SHALL show a red exclamation mark on the right side of each hive row when that hive requires attention, and the mark SHALL reveal the reason on hover or keyboard focus. When more than one attention condition is met simultaneously, all reasons SHALL be shown together (separated by " / ") in the tooltip and accessible label.

#### Scenario: Hive without a queen requires attention
- **GIVEN** a hive is in the Bezmatek state
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a red exclamation mark whose explanation says that the hive has no queen

#### Scenario: Overdue expected emergence requires attention
- **GIVEN** a hive is in the Matecznik state and its expected emergence date is before today's date
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a red exclamation mark whose explanation asks the user to check whether the queen emerged

#### Scenario: Overdue expected mating requires attention
- **GIVEN** a hive is in the Matka wygryziona state and its expected mating date is before today's date
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a red exclamation mark whose explanation says the expected mating date has passed

#### Scenario: Overdue 30-day insemination deadline requires attention
- **GIVEN** a hive is in the Matecznik (M) or Matka wygryziona (N) state
- **AND** more than 30 days have passed since the expected emergence date
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a red exclamation mark whose explanation says the 30-day insemination deadline has passed and the queen is still uninseminated

#### Scenario: Multiple conditions show all reasons
- **GIVEN** a hive meets more than one attention condition simultaneously (e.g. overdue expected mating date AND past 30-day insemination deadline)
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row shows a single red exclamation mark whose tooltip and accessible label contain all applicable reasons joined by " / "

#### Scenario: Hive without an overdue condition has no attention mark
- **GIVEN** a hive is not in the Bezmatek state and any applicable expected date is today or later
- **WHEN** the user views the mating-apiary hive list
- **THEN** the hive row does not show an attention mark

### Requirement: Mating apiary indicates hives requiring immediate attention
The mating-apiary card SHALL show a red exclamation mark when at least one mating hive in that apiary has an active attention condition, and the mark SHALL expose the names of all such hives on hover or keyboard focus.

#### Scenario: Apiary with one attention-required hive
- **GIVEN** a mating apiary contains a hive whose existing attention rules require action
- **WHEN** the user views the apiary list
- **THEN** the apiary card shows one red exclamation mark and its tooltip and accessible label contain the name of that hive

#### Scenario: Apiary with multiple attention-required hives
- **GIVEN** a mating apiary contains multiple hives whose existing attention rules require action
- **WHEN** the user hovers over or focuses the apiary alert
- **THEN** the tooltip and accessible label contain every affected hive name in the apiary's current hive-list order

#### Scenario: Apiary without attention-required hives
- **GIVEN** no hive in a mating apiary has an active attention condition
- **WHEN** the user views the apiary list
- **THEN** the apiary card does not show the red exclamation mark

#### Scenario: Alert is available by keyboard
- **GIVEN** a mating apiary has at least one attention-required hive
- **WHEN** the user moves keyboard focus to the apiary alert
- **THEN** the same affected-hive name list is available through the alert's accessible name and native tooltip without opening the apiary

#### Scenario: Commercial apiaries are unaffected
- **GIVEN** a commercial apiary is shown on the apiary list
- **WHEN** the user views the commercial apiary card
- **THEN** the card does not show a mating-hive attention alert
