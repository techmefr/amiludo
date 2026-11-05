# Feature Specification: European multilingual app and content

**Feature Branch**: `feat/i18n`

**Created**: 2026-11-05

**Status**: Draft

**Input**: User description: "The game must be multilingual for European languages."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Use the whole app in my language (Priority: P1)

A player picks a language and every screen, dialog, error and accessibility label appears in that language. The choice is remembered.

**Why this priority**: it is the base of everything else; today only French and English exist, with texts written inline in the code.

**Independent Test**: switch to German, open every main screen, no French or English text remains. Restart the app, German is still selected.

**Acceptance Scenarios**:

1. **Given** the language is set to Automatic on a device set to Spanish, **When** the app opens, **Then** it is in Spanish.
2. **Given** the language is set to Automatic on a device in an unsupported language, **When** the app opens, **Then** it is in English.
3. **Given** the language selector, **When** the player picks Italian, **Then** all screens switch to Italian immediately and the choice survives a restart.
4. **Given** any supported language, **When** a screen is shown, **Then** it contains no truncated or overflowing text at 1280x720, 1920x1080 and phone sizes.

---

### User Story 2 - Game content in several languages (Priority: P2)

Packs, cards, missions and episodes can carry a text per language. The player sees their language, and the English text when a translation is missing.

**Why this priority**: the app is a companion for game content; the interface alone is not enough.

**Independent Test**: a pack with French and German names shows the German name in German, and the English name when the player uses Dutch and no Dutch text exists.

**Acceptance Scenarios**:

1. **Given** a pack with a name in several languages, **When** displayed, **Then** the player's language is used.
2. **Given** a missing translation, **When** displayed, **Then** English is used, then the first available language.
3. **Given** an existing pack with plain text fields, **When** loaded, **Then** it still works unchanged.
4. **Given** a pack exported with translations, **When** imported, **Then** all languages are preserved.

---

### User Story 3 - No missing translation reaches players (Priority: P3)

Adding a language or a text cannot silently leave a gap.

**Why this priority**: gaps appear when texts are added by several people over time.

**Independent Test**: delete one key from a language file, the checks fail naming the language and the key.

**Acceptance Scenarios**:

1. **Given** every language file, **When** checks run, **Then** each has exactly the keys of the English file.
2. **Given** a text with placeholders, **When** checks run, **Then** every language uses the same placeholders.

### Edge Cases

- A translated text is much longer than the original (German): layouts must not overflow.
- Plurals differ per language: counted texts use proper plural rules.
- Dates, times and numbers follow the selected language.
- A language file contains a text the template does not know: rejected by checks.
- A stored language that is no longer supported: fall back to the device language, then English.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST support French, English, Spanish, German, Italian, Portuguese and Dutch at launch.
- **FR-002**: All interface texts MUST come from per-language files, none written inline in the code.
- **FR-003**: The player MUST be able to choose Automatic, which follows the device language when supported and English otherwise. The default stays French until the existing tests that assume it are deliberately updated.
- **FR-004**: The player MUST be able to change the language, shown with a flag and the native name, and the choice MUST persist.
- **FR-005**: Counted texts MUST use plural rules of each language.
- **FR-006**: Dates, times and numbers MUST be formatted for the selected language.
- **FR-007**: Pack and game content MUST accept a text per language with a documented fallback order.
- **FR-008**: Packs without translations MUST keep working unchanged.
- **FR-009**: Automated checks MUST fail when a language misses a key or uses different placeholders.
- **FR-010**: Accessibility labels MUST be translated like any other text.
- **FR-011**: Adding a new language MUST require only a new language file and its entry in the selector.

### Key Entities

- **Language file**: the set of interface texts for one language.
- **Supported language**: code, native name and flag shown in the selector.
- **Localized text**: a text with one value per language and a fallback order.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100 % of interface texts come from language files, with no inline text left.
- **SC-002**: Every supported language passes the completeness checks.
- **SC-003**: Switching language updates the whole visible screen without restart.
- **SC-004**: No overflow at the three tested screen sizes in any language.
- **SC-005**: Adding a new language takes one file and no code change outside the selector list.

## Assumptions

- English is the reference language of the files because the repository is in English.
- First translations are produced by drafting, then flagged for native review before being treated as final.
- Right-to-left and non-Latin scripts are out of scope for this lot.
- Voice narration (text to speech) per language is a separate later feature.
- The narrative names of the universe (city, machine, desert) are translated or kept as proper names case by case, decided when the first episode is written.
