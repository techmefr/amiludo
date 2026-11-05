# Feature Specification: Character creation with a visually assembled avatar

**Feature Branch**: `feat/character-assembly`

**Created**: 2026-11-05

**Status**: Draft

**Input**: User description: "Create a character quickly and playfully by opening a succession of boosters. The player first picks a base appearance, then opens one booster per category and keeps one card each. The chosen cards build both the character rules and the character picture through compatible layers. At the end the app shows the assembled character, its eight cards, its traits, abilities and items. Every combination must be playable. A missing asset never blocks a choice."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pick my base appearance (Priority: P1)

A player chooses a people, a body shape, a head, a skin tone, a hairstyle, optional details, and a name with pronouns. The character picture updates after each choice, and every choice stays editable during creation.

**Why this priority**: everything after builds on this base; the people also becomes the first of the eight cards.

**Independent Test**: choose a people, change the head and the hairstyle; the picture updates each time and the people appears as the first card.

**Acceptance Scenarios**:

1. **Given** the start screen, **When** a people is chosen, **Then** it becomes the first card of the sheet with its starting ability, without any random draw.
2. **Given** a chosen body shape, **When** a head or hairstyle is changed, **Then** compatible layers are shown and the previous outfit stays.
3. **Given** a feminine, masculine or androgynous look obtained from shape, face and hair, **When** cards are chosen, **Then** no card is restricted by that look.
4. **Given** a name and pronouns, **When** entered, **Then** no job or equipment constraint is applied.

---

### User Story 2 - Open boosters and keep one card each (Priority: P1)

After the base appearance, the player opens, in order, the job, background, equipment, weapon, outfit, quality and flaw boosters. Each reveals four cards without duplicates; the player keeps one and moves on. The picture updates with a preview of the selected card before it is confirmed.

**Why this priority**: it is the core loop and reuses the existing card pack mechanic.

**Independent Test**: complete the seven boosters; the sheet holds eight cards, the people plus seven chosen ones, and the picture shows the visible ones.

**Acceptance Scenarios**:

1. **Given** a closed booster, **When** touched, **Then** a short opening plays, skipped when reduced motion is on.
2. **Given** revealed cards, **When** a card is selected, **Then** the character shows a provisional preview, and the sheet is only changed on confirmation.
3. **Given** a confirmed card, **When** the next step is reached, **Then** the next booster opens.
4. **Given** a later step, **When** the player goes back, **Then** the same four cards of that booster are shown, not a new draw.
5. **Given** an interruption or app closing, **When** the app reopens, **Then** the character, the draws and the current step are restored.

---

### User Story 3 - See the finished character (Priority: P1)

A recap shows the assembled character, the eight cards, and the traits, abilities and objects computed from the cards, before the final validation.

**Why this priority**: it is the result the player came for.

**Independent Test**: validate a character; the recap lists eight cards and the computed traits, with or without images.

**Acceptance Scenarios**:

1. **Given** eight chosen cards, **When** the recap is shown, **Then** every card and its effects appear.
2. **Given** a card without illustration, **When** shown, **Then** the fallback visual is used.
3. **Given** missing layers, **When** the picture is built, **Then** the character is still shown and playable.

---

### User Story 4 - Layers that fit together (Priority: P2)

Each appearance element declares its slot, compatible shapes and peoples, layers, the body parts it hides and its variants, so the assembly has no gap at the neck, shoulders or hands, and a prosthesis hides the replaced limb.

**Why this priority**: the picture is only convincing if layers fit; it can be developed once the loop works.

**Independent Test**: assemble the demonstration character; neck, shoulders and hands align, the arm prosthesis hides the biological arm, the weapon appears held.

**Acceptance Scenarios**:

1. **Given** a prosthesis that replaces an arm, **When** assembled, **Then** the biological arm is hidden.
2. **Given** a head change, **When** assembled, **Then** the compatible hairstyle and outfit are kept.
3. **Given** an asset missing for a body shape, **When** assembled, **Then** the choice stays available and a visual fallback is used.

### Edge Cases

- Two cards occupying the same slot (equipment and weapon use reserved slots).
- A card with no appearance item: it only affects rules.
- A catalogue version change while a creation is in progress.
- Reduced motion, very small phones, 200 percent text.
- Back navigation after changing an earlier choice.
- No payment and no rarity affecting power: boosters are only a creation mechanism.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST offer a base appearance step with people, body shape, head, skin tone, hairstyle, optional details, name and pronouns, all editable during creation.
- **FR-002**: The people MUST be chosen directly and become the first card of the sheet.
- **FR-003**: The app MUST run seven boosters in order: job, background, equipment, weapon, outfit, quality, flaw, with four cards revealed and one kept by default, no duplicate in a booster.
- **FR-004**: A provisional selection MUST only be previewed; confirmation MUST record it.
- **FR-005**: Going back MUST keep the same draws; the app MUST save automatically and resume after closing.
- **FR-006**: A recap MUST be shown before final validation.
- **FR-007**: The character picture MUST be assembled from layers in a defined drawing order.
- **FR-008**: Rule data and appearance data MUST be separate; a card references an appearance item by identifier.
- **FR-009**: An appearance item MUST declare slot, compatible shapes and peoples, layers per variant and body parts to hide.
- **FR-010**: Rule effects MUST be computed from the cards and never depend on images.
- **FR-011**: A missing card image or layer MUST fall back to a visual and never block a choice.
- **FR-012**: The saved character MUST store appearance choices, the eight card identifiers, the draws of each booster, the current step and the catalogue version.
- **FR-013**: Animations MUST honour reduced motion; the whole flow MUST work with animations off.
- **FR-014**: All texts MUST go through localizations in the seven languages; card texts use name and description keys.
- **FR-015**: Asset files MUST be lowercase, digits and hyphens, no accent or space, extension png, at most 80 characters.
- **FR-016**: Card illustrations are 1024x1024 PNG with a flat sand background and no text, digit, frame or interface; character layers are 1024x1024 transparent PNG on one shared canvas, never auto-cropped, with identical attachment points per body shape.

### Key Entities

- **Card**: id, type, name key, description key, illustration path, rule effects, appearance item id.
- **Appearance item**: id, slot, variants per body shape, each with layers (order, source) and hidden body parts.
- **Character draft**: appearance choices, eight card ids, draws per booster, current step, catalogue version.
- **Catalogue**: versioned set of cards and appearance items.

## Success Criteria *(mandatory)*

- **SC-001**: A player completes a character in under five minutes.
- **SC-002**: The demonstration assembly shows no visible gap at neck, shoulders or hands.
- **SC-003**: A draft survives closing and reopening with the same draws and step.
- **SC-004**: The recap shows eight cards and computed traits with zero images.
- **SC-005**: Every combination of proposed cards is playable.

## Assumptions

- The eight peoples of the first brief remain a working base, to confirm before production.
- First prototype: two body shapes sharing one pose; only one is built in the demonstration lot.
- Peoples differ mostly by heads, ears, skin tones and marks; very different anatomies are an extension.
- Generated images are checked and realigned by hand; generation alone does not guarantee exact fits.
- The existing card pack mechanic (draw, keepMin, keepMax) and the `assets/cards` loader are reused.
- Quantities: 66 card illustrations from the first families, plus 8 qualities and 8 flaws, 82 card illustrations including the style reference; layers depend on validated variants.
