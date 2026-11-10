# Feature Specification: Character creation sessions with card packs (bundle mode)

**Feature Branch**: `character-card-packs`

**Created**: 2026-11-10

**Status**: Draft

**Input**: User description: "Bundle mode: the game master creates a session, picks cards or leaves it free, and the players open packs of cards, discover them and say which ones they keep to create their character."

## Existing building blocks reused

- Pack template creation stages (`GameTemplate.creation`, `CreationCategory` with draw, keepMin, keepMax) and `CharacterCard`.
- Pack opening animation (`PackStage`, `PackIdle`, `TarotFace`, `TarotBack`) and the `RandomTools` shuffle.
- Immersive page layout, tokens, `design_tokens_test`, the tool catalog, the tool shelves and the router registry.
- Document store, `StoredDocument` and `BackupSection` for persistence and backup.
- Lobby (`/lobby`, `/join/:code`, `RoomChannel`, LAN and remote rooms) for multi-device play.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Set up a character creation session (Priority: P1)

The game master picks a pack template, chooses the card pool per category (race or origin, class, trait, flaw, gear, bond, editable decks) or leaves it free (all cards of the universe), and sets the rules: cards per pack, packs per player, cards a player may keep per category (keep N of M), duplicates allowed or not, rerolls, and reveal mode (hidden until everyone opened, or live).

**Independent Test**: open the setup, pick a pool, change each rule, start; the session holds exactly those rules.

**Acceptance Scenarios**:

1. **Given** a pack template, **When** the setup opens, **Then** every category of the template is a deck that can be enabled, disabled and edited card by card.
2. **Given** free mode, **When** the session starts, **Then** every card of every category is in the pool.
3. **Given** rules that cannot be satisfied (fewer cards than the pack size without duplicates, keep above pack size), **When** starting, **Then** start is refused with the reason shown.
4. **Given** a valid setup, **When** started, **Then** one sealed pack per category per player is dealt, seeded so that a restart reproduces it.

---

### User Story 2 - Open packs and discover cards (Priority: P1)

Each player gets sealed packs, opens them with the premium opening animation, and cards are revealed one by one with a flip. Rarity (common, rare, holo, ultra) is shown on each card; holo and ultra have a holographic foil that follows the pointer or the gyroscope.

**Independent Test**: open a pack; the cards flip one by one and the rarity of each is visible without relying on color alone.

**Acceptance Scenarios**:

1. **Given** a sealed pack, **When** opened, **Then** the animation plays, then each card is revealed by a flip.
2. **Given** reduced motion or no shader support, **When** a holo card is shown, **Then** a sober static sheen and a text rarity label replace the foil.
3. **Given** duplicates not allowed, **When** packs are dealt, **Then** no card appears twice for the same player.
4. **Given** reveal mode hidden, **When** a player opened all packs, **Then** their cards stay hidden from the board until everyone opened.

---

### User Story 3 - Keep or discard (Priority: P1)

After revealing a pack, the player taps cards to keep or discard them, sees a counter per category (kept / allowed), and validates when the limits are met. A reroll replaces a pack with a new deal while rerolls remain.

**Independent Test**: keep more than the limit; the extra card is refused; validation is enabled only when every category is within its keep range.

**Acceptance Scenarios**:

1. **Given** keep N of M, **When** the player keeps N cards, **Then** other cards of that pack cannot be kept until one is dropped.
2. **Given** fewer than keepMin kept, **When** validating, **Then** validation is disabled and the missing count is shown.
3. **Given** a reroll left, **When** used, **Then** the pack is replaced by new cards and the reroll count decreases, never below zero.

---

### User Story 4 - The sheet builds itself (Priority: P1)

Kept cards compose the character sheet automatically: categories map to sheet fields. The sheet is readable on screen and exportable as a shareable image.

**Independent Test**: validate a character; the sheet shows each category with its kept cards and can be shared as a PNG.

---

### User Story 5 - The game master sees a live board (Priority: P2)

The game master sees who opened which pack and what each player kept, live on the lobby channel when players use their own phones, or on one device in pass-the-phone mode.

## Flow

1. Setup (game master), then Start.
2. Per player: packs list, open, reveal, keep, validate, next pack, sheet.
3. Board for the game master throughout.

Delivery: single device (pass the phone) first. Multi-device reuses the existing lobby room channel with the session rules and the player results as messages; it is a later increment and is stated as not available until then.

## Data model

- **CardRarity**: common, rare, holo, ultra. Deterministic from the card (seeded weighted draw).
- **PackRules**: cardsPerPack, packsPerPlayer, keep per category (min, max), duplicates, rerolls, reveal mode.
- **PackPool**: per category, the enabled cards; free mode means every card.
- **SealedPack**: category, cards, rerollsUsed.
- **PlayerPacks**: player name, packs, kept card names per category, validated.
- **CardPackSession**: id, template name, rules, pool, seed, players, createdAt. Persisted in its own document `card_packs`, included in the backup, restored after closing.

## Requirements *(mandatory)*

- **FR-001**: The setup MUST expose pool, free mode, and every rule listed above, validated before start.
- **FR-002**: Dealing MUST be deterministic for a given seed and honour duplicates and pack size.
- **FR-003**: Keep limits MUST be enforced per category and validation MUST require every category within its range.
- **FR-004**: Rerolls MUST never go below zero and MUST replace only the chosen pack.
- **FR-005**: Rarity MUST be visible as text and icon, never by color alone; the foil MUST be a fragment shader with a sober fallback in reduced motion and where shaders are unsupported.
- **FR-006**: The sheet MUST map categories to sheet fields automatically and export an image.
- **FR-007**: The session MUST persist, be restorable and be part of the backup.
- **FR-008**: The flow MUST use the immersive layout: back and tabs on one row, 44dp targets, AA contrast, responsive at 375, 768, 1280 and landscape.
- **FR-009**: All texts MUST go through ARB in the seven languages; no comments in code; tokens only; files under 200 lines.
- **FR-010**: Technical layers MUST NOT import functional layers; the tool is registered in the catalog, shelves and router.

## Edge Cases

- A template with a single category; a category with fewer cards than the pack size.
- Free mode on a universe with no cards: start refused.
- A player removed mid-session; a name used twice.
- Closing the app between two packs: the deal and choices are restored.
- 200 percent text, very small phones, offline: the whole single-device flow works offline.

## Accessibility

Targets at least 44dp, AA contrast, semantic labels with rarity and kept state, focus order top bar then content, reduced motion skips animations and the foil, counters announced as live regions.

## Offline behaviour

Single-device play needs no network. Multi-device needs the lobby channel (same Wi-Fi or remote); when it drops, each phone continues locally and syncs results when reconnected.

## Success Criteria

- **SC-001**: A table of four creates characters in under ten minutes.
- **SC-002**: Keep limits are never exceeded in any sequence of taps (tested).
- **SC-003**: A session survives closing and reopening with the same deal.
