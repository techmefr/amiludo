# Feature Specification: Polished, Apple-like interface

**Feature Branch**: `feat/design`

**Created**: 2026-11-05

**Status**: Draft

**Input**: User description: "Finish the app with an Apple-like look: simple to use, appealing, makes people want to play."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A first launch that makes me want to play (Priority: P1)

A new player opens the app and understands in a few seconds what it does and what to tap first, without reading a manual.

**Why this priority**: the first impression decides whether the app is kept.

**Independent Test**: open a fresh install at 390x844, 1280x720 and 1920x1080; the home screen shows one clear primary action, a short promise, and the tools as large, calm tiles.

**Acceptance Scenarios**:

1. **Given** a fresh install, **When** the app opens, **Then** the home screen has one primary action and no more than two levels of choices.
2. **Given** an empty library or history, **When** shown, **Then** an empty state explains the screen and offers the next action.
3. **Given** any size from phone to 23-inch screen, **When** the home screen is shown, **Then** no text is cut and nothing is cramped.

---

### User Story 2 - One coherent look across every screen (Priority: P1)

Every screen uses the same spacing, type scale, corner radius, elevation, colour roles and icon style, so the app feels like one product.

**Why this priority**: screens were built separately and the skins differ in radius and weight.

**Independent Test**: open the 22 screens listed in the plan; each uses design tokens only, no hard-coded size, colour or font.

**Acceptance Scenarios**:

1. **Given** the design tokens, **When** a screen is built, **Then** spacing comes from one scale, text from one type scale, colours from the colour scheme.
2. **Given** the light and dark modes and every skin, **When** a screen is shown, **Then** text keeps readable contrast.
3. **Given** a skin change, **When** applied, **Then** the structure and spacing stay identical and only colour, font and accent change.

---

### User Story 3 - Fluid, calm motion (Priority: P2)

Transitions, taps and lists react with short, natural motion that never slows the player down.

**Why this priority**: motion is a large part of the Apple feel, as long as it stays discreet.

**Independent Test**: open a pack, switch tabs, open a sheet; each transition lasts under 350 ms and is skipped when the system asks to reduce motion.

**Acceptance Scenarios**:

1. **Given** reduced motion on the device, **When** navigating, **Then** transitions are instant.
2. **Given** a tap on a tile or button, **When** pressed, **Then** a subtle pressed state shows immediately.
3. **Given** a list that loads, **When** content arrives, **Then** it appears without a jump.

---

### User Story 4 - Easy for everyone (Priority: P2)

Targets are large enough, labels are clear, and the app can be used with a screen reader and large text.

**Why this priority**: simple to use is a stated goal, and accessibility is expected by default.

**Independent Test**: set text to 200 percent and a screen reader on; the main flows stay usable.

**Acceptance Scenarios**:

1. **Given** any interactive element, **When** measured, **Then** its target is at least 44 by 44 logical pixels.
2. **Given** text scaled to 200 percent, **When** a main screen is shown, **Then** nothing overflows and content scrolls.
3. **Given** an icon-only button, **When** read by a screen reader, **Then** it has a label in the player language.

### Edge Cases

- Long German and Dutch words in tiles and buttons.
- Very small phones (320 px wide) and very large screens.
- Dark mode with each skin.
- Right to left is out of scope.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST define design tokens (spacing, radius, elevation, type scale, motion durations) in the technical Theme layer.
- **FR-002**: Every screen MUST use the tokens and the colour scheme, with no hard-coded values.
- **FR-003**: The home screen MUST present one primary action and the tools as large tiles.
- **FR-004**: Every list and screen MUST have a designed empty state, a loading state and an error state.
- **FR-005**: Navigation MUST be reachable in at most two taps from home for any main tool.
- **FR-006**: Motion MUST follow the tokens and honour the reduced motion setting.
- **FR-007**: Interactive targets MUST be at least 44 by 44 logical pixels.
- **FR-008**: Existing skins MUST keep working with the same structure.
- **FR-009**: The result MUST be checked at 390x844, 1280x720 and 1920x1080 in light and dark modes.
- **FR-010**: No texts are hard-coded; all go through localizations.

### Key Entities

- **Design tokens**: spacing, radius, elevation, type scale and motion values shared by all screens.
- **Component set**: the shared tiles, buttons, sheets, empty states and headers built on the tokens.

## Success Criteria *(mandatory)*

- **SC-001**: A new player reaches a first dice roll or game in under 30 seconds without help.
- **SC-002**: All 22 screens pass the layout checks at the three sizes in both modes.
- **SC-003**: No hard-coded size, colour or font remains in presentation code, verified by a test.
- **SC-004**: Main flows work at 200 percent text and with a screen reader.

## Assumptions

- The design pass follows the order: tokens, component set, home, then each feature.
- The initiation game, reachable from a Bonus button, comes after this pass and reuses the component set.
- Visual review is done on screenshots at the three sizes, validated by the owner before merge.
