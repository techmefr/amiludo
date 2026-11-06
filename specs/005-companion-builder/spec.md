# Feature Specification: Companion builder from independent bricks

**Feature Branch**: `feat/companion-builder`

**Created**: 2026-11-06

**Status**: Draft

**Input**: User description: "The app is a builder to play many games: Yahtzee, poker with chips and counters, role-playing games, Dice Throne, Toy Battle, tag team games and others. Every element is independent (counter, life counter, score, chips, timer, hourglass that changes flow when turned, dice tray with physical dice and shaking, cards, character sheet, generators, status trackers) and elements can be combined to make the companion of one's own game. The app is only the companion of a game: it never recreates a game, its cards or its rules, and the player types whatever names and values their own game needs."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Build the companion of my game (Priority: P1)

A player names a game, adds bricks to a table, sets each brick up, and starts playing. No code and no game-specific screen is needed.

**Why this priority**: it is the product promise; every other story reuses it.

**Independent Test**: build a Yahtzee companion with a dice tray and a score sheet, then play a turn.

**Acceptance Scenarios**:

1. **Given** an empty companion, **When** a brick is added, **Then** it appears with sensible defaults and can be set up at once.
2. **Given** several bricks, **When** the player reorders, resizes or removes one, **Then** the others keep their state.
3. **Given** a finished companion, **When** the player starts a session, **Then** all bricks are shown full screen with a single discreet back button.
4. **Given** the same brick used twice, **When** each is set up differently, **Then** both work independently.

---

### User Story 2 - Count anything: points, life, chips (Priority: P1)

A counter has a name, an icon, a start value, bounds, a step, a color and a display (number, bar, hearts, pips). It can belong to one player, one team, or the whole table. Life, energy, combat points, poker chips and the pot are all counters.

**Why this priority**: it covers life counters, scores and chips, the most common need.

**Independent Test**: create a life counter at 50 with a bar display and a combat-points counter capped at 15 for two players; change them during a session.

**Acceptance Scenarios**:

1. **Given** a counter with bounds, **When** a change would pass a bound, **Then** the value stops at the bound.
2. **Given** a counter set to react at zero, **When** it reaches zero, **Then** the configured outcome is shown (eliminated, loses a turn, or nothing).
3. **Given** quick values and a custom entry, **When** used, **Then** the change is applied and kept in the history with an undo.
4. **Given** a player zone turned toward its player, **When** two or more players face each other, **Then** each reads and edits their own counters.

---

### User Story 3 - Teams, tag team and several heroes (Priority: P2)

Players are grouped in teams. A team can hold several heroes of which one is active, and the active hero can be switched. Each hero keeps its own counters and statuses.

**Why this priority**: tag team and team games need it; it builds on counters.

**Independent Test**: two teams of two heroes; switching the active hero keeps each hero's life and statuses.

**Acceptance Scenarios**:

1. **Given** a team of heroes, **When** another hero becomes active, **Then** the previous one keeps its values.
2. **Given** a team total, **When** a hero changes, **Then** the total updates.

---

### User Story 3b - Heroes with powers that charge (Priority: P2)

A hero has a tile with its name, an optional picture and its powers, its own point counter, and its own way of charging each power. A power shows whether it is charging, ready or used. Charging can come from the hero's points reaching a threshold, from a fixed amount each turn, from an event the player marks, or by hand.

**Why this priority**: it is how tag team style games work and it generalizes to abilities in any game.

**Independent Test**: a hero with one power that needs ten points; reaching ten points makes it ready, using it spends the points and starts charging again.

**Acceptance Scenarios**:

1. **Given** a power charged by points, **When** the hero's counter reaches the threshold, **Then** the power becomes ready.
2. **Given** a power charged by turns, **When** the round advances, **Then** its charge grows by the configured amount.
3. **Given** a ready power, **When** used, **Then** it spends its cost and returns to charging, or to used if single-use.
4. **Given** two heroes with different ways of charging, **When** played, **Then** each follows its own rule.

---

### User Story 4 - Time that feels physical (Priority: P2)

An hourglass brick flows sand with a chosen duration. Turning the phone reverses the flow and keeps the elapsed time. Without a motion sensor a button does the same. A per-player clock and a round counter are also available.

**Why this priority**: gives bricks a tactile identity and serves turn-based games.

**Independent Test**: start a one-minute hourglass, turn the phone after twenty seconds; forty seconds of sand remain on the other side.

**Acceptance Scenarios**:

1. **Given** a running hourglass, **When** the phone is turned, **Then** the flow reverses and nothing is reset.
2. **Given** a finished hourglass, **When** it ends, **Then** a vibration and an optional sound play.
3. **Given** reduced motion, **When** shown, **Then** sand is shown without grain animation.

---

### User Story 5 - Throw dice on a tray (Priority: P1)

The player chooses dice (kind, count, look), then shakes the phone. The dice are thrown on a tray with physics, settle, and the faces are read. Without a sensor a button or a swipe throws.

**Why this priority**: dice are central to Yahtzee, Dice Throne and role-playing.

**Independent Test**: choose five six-sided dice, shake; the five results are read and shown.

**Acceptance Scenarios**:

1. **Given** chosen dice, **When** the phone is shaken, **Then** the dice bounce, collide, settle and the total is shown.
2. **Given** dice kept aside between throws, **When** thrown again, **Then** only the other dice are thrown.
3. **Given** custom faces, **When** thrown, **Then** the custom face is shown and read.

---

### User Story 6 - Share my companion setup (Priority: P2)

A companion can be exported and shared as one file holding only its bricks and settings, and opened on another device or by a friend.

**Why this priority**: lets players reuse and exchange setups without the app holding any game content.

**Independent Test**: export a companion, import it on a clean install, and get the same bricks and settings.

**Acceptance Scenarios**:

1. **Given** a companion, **When** exported and imported, **Then** bricks and settings are identical and no game content is included.
2. **Given** an incompatible version, **When** imported, **Then** the player is told what is unsupported and nothing is lost.

---

### Edge Cases

- A brick type unknown to this app version is kept and shown as unavailable, never dropped.
- A very small or very large screen keeps every brick reachable.
- Interrupting the app restores every brick's state.
- Two players editing the same counter at once keep both changes in the history.
- Rules of a game are only those the player configures; the app never claims official rules.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A companion MUST be described by data only: a list of bricks, each with a type, settings and an owner (player, team, table).
- **FR-002**: Every brick MUST work on its own and inside any companion.
- **FR-003**: The counter brick MUST support name, icon, start value, minimum, maximum, step, color, display and outcome at a bound.
- **FR-004**: A life counter MUST be a counter preset, not a separate brick.
- **FR-005**: Players, teams and heroes MUST be able to own bricks, with an active hero per team.
- **FR-005b**: A hero MUST hold a tile, a point counter and powers, and each power MUST have its own charge rule (points threshold, amount per turn, marked event, or manual) and a state (charging, ready, used).
- **FR-005c**: The app MUST NOT ship, require or reproduce the cards, boards, texts or rules of any published game; names, values and pictures are entered by the player.
- **FR-006**: The hourglass MUST reverse on a physical turn when a sensor exists and offer a button otherwise.
- **FR-007**: The dice tray MUST use a physics simulation, support the common dice kinds, custom faces and keeping dice aside.
- **FR-008**: Shake detection MUST have a non-sensor fallback and a sensitivity setting.
- **FR-009**: Every change MUST be recorded in a history with undo.
- **FR-010**: Every brick MUST be usable full screen with a single discreet back button.
- **FR-011**: Companions MUST be exportable and importable as one versioned file holding bricks and settings only.
- **FR-012**: Unknown bricks or fields MUST be preserved on import.
- **FR-013**: All texts MUST be translated, and bricks MUST be accessible by screen reader and at large text sizes.
- **FR-014**: Reduced motion MUST remove physics animation without removing results.
- **FR-015**: The app MUST ship generic starting setups (dice and score sheet, chips and pot, heroes with counters) built only from bricks, without naming or reproducing a published game.

### Key Entities

- **Companion**: name, version, bricks, players, teams.
- **Brick**: type, settings, owner, layout position.
- **Counter settings**: name, icon, start, bounds, step, display, outcome.
- **Hero**: name, optional picture, counters, statuses, powers, team, active flag.
- **Power**: name, text, cost, charge rule, charge level, state.
- **Dice set**: kinds, count, look, custom faces.
- **Companion file**: versioned export holding everything above.

## Success Criteria *(mandatory)*

- **SC-001**: A player builds a working Yahtzee companion in under five minutes without help.
- **SC-002**: Every ready-made example is built only from bricks, with no game-specific screen.
- **SC-003**: An exported companion reopens identically on a clean install.
- **SC-004**: Every brick is usable and readable at 1280×720 and 1920×1080 and on a phone in both orientations.

## Assumptions

- Rules of specific games (Dice Throne, Toy Battle, tag team) are given by the player as settings; the app only provides bricks.
- The player keeps the physical game (cards, boards, box); the app only counts, rolls, times and tracks, so the app plus the player's own deck is enough to play.
- Tag Team style games are served by generic bricks: a tile per fighter with its life and power counters and a charge rule the player sets; the app never carries the fighters, cards or rules.
- The shake sensor is available on phones and absent on web and desktop.
- The video-game look is a style option and is specified separately.
