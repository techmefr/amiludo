# Feature Specification: Card packs character creation

**Feature Branch**: `feat/card-packs`

**Created**: 2026-11-05

**Status**: Draft

**Input**: User description: "Open a pack, pick a card, repeat for each type (race, trade, background, gear, weapon, outfit, quality, flaw). The combined cards make the character. Each pack is one type so it stays simple and can be replayed. Illustrations arrive progressively."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Build a character by opening packs (Priority: P1)

A player opens one pack per card type. Each pack reveals a few cards with a flip animation, the player keeps the allowed number of cards, then the next pack appears. When the last pack is done, the kept cards stack into a character sheet that can be named and saved.

**Why this priority**: it is the core loop of the initiation mode and works with the data the app already has (categories with draw, keepMin and keepMax).

**Independent Test**: open a pack with 3 categories, keep one card in each, name the character and save it. The saved sheet lists the three kept cards.

**Acceptance Scenarios**:

1. **Given** a pack with several categories, **When** the player starts creation, **Then** the first category is shown as a closed pack of its type.
2. **Given** a closed pack, **When** the player opens it, **Then** the offered cards are revealed one by one with a flip animation.
3. **Given** revealed cards, **When** the player keeps between keepMin and keepMax cards and confirms, **Then** the next pack appears.
4. **Given** the last pack is confirmed, **When** the player names the character, **Then** the sheet is saved with every kept card.
5. **Given** a saved character, **When** the player starts a new creation, **Then** the packs are drawn again and can give different cards.

---

### User Story 2 - Cards carry an illustration that can arrive later (Priority: P2)

A card can reference a bundled illustration. When the image exists it is shown on the card and the sheet. When it is missing, the card shows the type icon so nothing breaks.

**Why this priority**: the artwork is produced separately and will land card by card.

**Independent Test**: add an image to one card only. That card shows the image, the others show the icon.

**Acceptance Scenarios**:

1. **Given** a card with an image reference to an existing asset, **When** it is displayed, **Then** the image fills the card art area.
2. **Given** a card with no image or an unknown reference, **When** it is displayed, **Then** the type icon is shown and no error appears.
3. **Given** an exported pack, **When** it is imported again, **Then** image references are preserved.

---

### User Story 3 - Pack opening is accessible and fast (Priority: P3)

The reveal animation can be skipped, respects the reduced motion setting and every card is reachable with a screen reader.

**Why this priority**: accessibility is expected by default and the effect must not slow repeat players.

**Independent Test**: enable reduced motion, open a pack, cards appear without animation and each has a readable label.

**Acceptance Scenarios**:

1. **Given** reduced motion is enabled, **When** a pack opens, **Then** cards appear instantly.
2. **Given** an animation in progress, **When** the player taps skip, **Then** all cards are revealed.
3. **Given** a screen reader, **When** cards are revealed, **Then** each announces its type, name and description.

### Edge Cases

- A category with fewer cards than the draw size offers all its cards.
- A player leaves mid creation: choices made so far are restored on return.
- A card with a very long name or description stays readable without breaking the layout on 1280x720 and 1920x1080 screens.
- An image fails to load: the icon fallback is used.
- Importing a pack with an invalid image reference rejects only that reference.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST present each creation category as a closed pack named after its type.
- **FR-002**: Opening a pack MUST reveal its offered cards with a flip animation that can be skipped.
- **FR-003**: The player MUST keep between keepMin and keepMax cards before moving to the next pack.
- **FR-004**: The system MUST stack the kept cards into a character sheet at the end and let the player name and save it.
- **FR-005**: The system MUST restore an unfinished creation after the app is closed.
- **FR-006**: A card MAY reference a bundled image; a missing image MUST fall back to the type icon.
- **FR-007**: Image references MUST survive pack export and import and be validated on import.
- **FR-008**: All displayed texts MUST come from the translation system.
- **FR-009**: The reveal MUST honour the reduced motion setting and expose accessible labels.
- **FR-010**: The feature MUST work offline.

### Key Entities

- **Creation category (pack)**: a card type with its cards, number offered, minimum and maximum kept. Already exists.
- **Character card**: name, description and an optional image reference.
- **Game character**: saved sheet made of the kept cards per category. Already exists.
- **Creation draft**: the in-progress choices, now persisted.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new player builds a character from 8 packs in under 3 minutes.
- **SC-002**: Reopening the app mid creation returns to the same pack with the same choices.
- **SC-003**: A card without image renders without any visible error.
- **SC-004**: The full flow works with reduced motion and with a screen reader.

## Assumptions

- The existing booster mode (draw, keepMin, keepMax) is the mechanism behind packs; this feature adds the experience, persistence and images.
- Images are bundled with the app or its downloadable pack, never fetched from an arbitrary URL.
- Later lots (not in this spec): character sheet fields and states, backpack, map tracking, mission and season format, narrator voice, codex.
