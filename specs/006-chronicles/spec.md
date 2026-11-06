# Feature Specification: Chronicles, a character generator by boosters

**Feature Branch**: `chronicles-boosters`

**Created**: 2026-11-06

**Status**: Draft

**Input**: User description: "The player builds a character in five steps: general information, physical appearance, personality and abilities, past, present. They choose one of four universes. Per step, a list of card types with minimum and maximum quotas. For each booster they choose an edition, tear it, discover five cards one by one and keep or pass each one. Destiny can complete the missing cards. A final sheet shows the portrait, name, epithet, global rarity, six stats, the five sections and the kept cards, with text, JSON and native share exports."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Build a character step by step (Priority: P1)

A player picks a universe (medieval fantasy, science-fiction, cyberpunk, gothic horror) and goes through five steps. In each step the types to fill and their quotas come from the content file. The step ends when every minimum is met.

**Why this priority**: it is the core loop and extends the existing character generator.

**Independent Test**: start a game on the sample content, keep cards until every minimum is met, reach the final sheet.

**Acceptance Scenarios**:

1. **Given** the home or the character generator, **When** Chronicles is opened, **Then** the four universes are offered, or the running game is resumed.
2. **Given** a step, **When** every type has reached its minimum, **Then** the next step starts, and after step five the sheet is shown.
3. **Given** a type with no compatible card left, **When** the minimums are checked, **Then** that type counts as filled.
4. **Given** the app is closed at any moment, **When** it reopens, **Then** the same universe, step, booster, position and kept cards are restored.

### User Story 2 - Open boosters and decide card by card (Priority: P1)

The player picks an edition among three (Fer favors force and will, Vent agility and perception, Esprit intelligence and charisma), tears the booster and discovers five cards one by one. Common and uncommon cards are face up. Rare and above are face down and must be flipped. Each card is kept or passed.

**Independent Test**: open a booster, flip a rare card, keep one card, pass another, see the recap.

**Acceptance Scenarios**:

1. **Given** a discovered card whose type is full or which conflicts with a kept card, **When** the player keeps it, **Then** it is refused with a message and stays on the table until passed.
2. **Given** the five cards decided, **When** the booster ends, **Then** a recap lists the cards kept from it.
3. **Given** missing minimums, **When** the player lets destiny complete, **Then** compatible cards, preferably common or uncommon, are added up to the minimums and marked as chosen by destiny.
4. **Given** reduced motion, **When** a card is flipped or a booster torn, **Then** no animation plays.

### User Story 3 - Read the final sheet (Priority: P1)

The sheet shows name and nickname, epithet, global rarity, six stats, the five sections field by field and the kept cards. It can be exported as text, as JSON, shared natively and saved with the existing characters.

**Acceptance Scenarios**:

1. **Given** destiny cards, **When** stats and rarity are computed, **Then** they are ignored.
2. **Given** no epithet card, **When** the sheet is built, **Then** the universe default epithet is used.

### User Story 4 - Cards that feel like cards (Priority: P2)

Card faces are painted with a procedural sigil, a rarity border and a holographic band from Rare. Flipping uses a perspective turn. Cards are kept or passed by swiping, the booster is torn by a horizontal drag, editions are browsed in a carousel. Particles, halo and flash play only when animations are not reduced. A procedural portrait is drawn on the sheet.

## Requirements *(mandatory)*

- **FR-001**: Content is read from `assets/chronicles/chronicles-data.json` with keys `caracteristiques`, `raretes`, `etapes`, `editions`, `univers`, `libellesCourts`, `cartes`. The shipped file is a small original sample with the same schema and is replaced later by the full content.
- **FR-002**: Types and their minimum and maximum come from `etapes`, never from code.
- **FR-003**: Rarities c 45 percent score 1, u 27 percent 2, r 15 percent 3, e 8 percent 4, l 4 percent 5, m 1 percent 6. When no card exists for the drawn rarity the nearest lower then higher rarity is used.
- **FR-004**: Draw weight per candidate: times 2 when it favors the edition, times 3 when its type has not reached its minimum, divided by 1 plus 2 times the cards of the same type already drawn in the booster. A type with maximum 1 appears once per booster. Cards already seen in the step are avoided while others remain. Kept and blocked cards are excluded.
- **FR-005**: A card is blocked when its type quota is reached or when its `conflits` contains a tag of another kept card, in both directions.
- **FR-006**: Stats start at 8, add the modifiers of kept non-destiny cards, clamped from 3 to 24.
- **FR-007**: Global rarity is the mean rarity score of kept non-destiny cards, plus 0.6 if any is legendary or mythic, rounded, capped at 6.
- **FR-008**: Name is the name card plus the nickname card if any. Epithet is that of the rarest kept non-destiny card that has one, else the universe default.
- **FR-009**: Progress is saved after every action in its own stored document and resumed; an unreadable save is ignored.
- **FR-010**: Randomness is injected through the existing `RandomTools`.
- **FR-011**: Card texts come from the JSON, interface texts from the seven ARB languages.
- **FR-012**: Existing generator pieces are reused: `CharacterCard` for display, `CardFace`, `CharacterSheetStack`, `GameCharacter` for saving.

## Success Criteria

- **SC-001**: a full game runs on the sample content in unit and widget tests at 390x844 and 1280x720.
- **SC-002**: over 10000 drawn cards each rarity stays within 1.5 points of its weight.
- **SC-003**: no test depends on the number of cards; one test only runs when the file holds 223 cards.
