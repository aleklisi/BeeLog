# Spec Delta

## Purpose

Provides a consistent main menu for navigating BeeLog's primary views, settings, and sign-out while respecting each user's enabled modules.

## ADDED Requirements

### Requirement: Open and operate the main menu
The application SHALL provide a three-line menu button that opens and closes the primary navigation menu and is usable by keyboard and touch.

#### Scenario: Open and close the menu
- **WHEN** a signed-in user activates the menu button
- **THEN** the menu opens, exposes its navigation entries, and reports its expanded state; activating it again closes the menu

#### Scenario: Operate the menu with a keyboard
- **WHEN** a signed-in user navigates to the menu button with a keyboard and activates it
- **THEN** the menu opens and its entries can be reached and activated by keyboard

### Requirement: Show enabled primary views
The main menu SHALL show Queen Rearing, Mating Apiaries, and Commercial Apiaries only when the corresponding module is enabled for the signed-in user. Queen Rearing SHALL be shown only when the module is available and enabled.

#### Scenario: Show only enabled modules
- **GIVEN** mating and commercial apiaries are enabled and queen rearing is disabled
- **WHEN** the user opens the main menu
- **THEN** the menu shows Mating Apiaries and Commercial Apiaries and omits Queen Rearing

#### Scenario: Open an enabled view
- **GIVEN** a primary view is enabled
- **WHEN** the user selects its menu entry
- **THEN** the application opens that view

### Requirement: Keep settings and logout available
The main menu SHALL always show Settings and Logout to a signed-in user, including when every optional module is disabled.

#### Scenario: Settings remain available without optional modules
- **GIVEN** all optional modules are disabled
- **WHEN** the user opens the main menu
- **THEN** Settings and Logout remain visible and Settings can be opened

#### Scenario: Sign out from the menu
- **WHEN** the user selects Logout
- **THEN** the application signs the user out

### Requirement: Handle disabling the current view
When a user disables the module for the currently open primary view, the application SHALL leave that view and open an enabled primary view or Settings.

#### Scenario: Disable the currently open module
- **GIVEN** the user is viewing Mating Apiaries
- **WHEN** the user disables Mating Apiaries in Settings
- **THEN** the application leaves that view and opens an enabled primary view or Settings
