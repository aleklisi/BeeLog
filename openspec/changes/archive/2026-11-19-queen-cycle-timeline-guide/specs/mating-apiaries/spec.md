# Spec Delta

## MODIFIED Requirements

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
