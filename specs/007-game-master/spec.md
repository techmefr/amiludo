# Feature Specification: Game master companion

**Feature Branch**: `gm-companion`

**Created**: 2026-11-08

**Status**: Draft

**Input**: User description: "A companion for the game master of a tabletop role-playing game, played around a real table, offline, phone first: initiative and turn by turn combat, creature and NPC sheets, a bestiary, campaign notes, a story map, sound ambience, 3D dice and generators. Strictly generic: no licensed rules text, no licensed stat blocks."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find the game master tools in one place (Priority: P1)

A game master opens the tools and finds a dedicated shelf, Game master, that gathers every tool useful behind the screen.

**Independent Test**: open the tools menu, open the shelf, see the tools it holds.

**Acceptance Scenarios**:

1. **Given** the tools menu, **When** it is shown, **Then** a Game master shelf with its own look is offered, translated in the seven languages.
2. **Given** the shelf, **When** it is opened, **Then** the NPC, encounter, treasure, tavern, rumour, villain and quest tools are listed, each on exactly one shelf.
3. **Given** the companion builder, **When** a brick is added, **Then** the Game master shelf appears in the picker.

### User Story 2 - Run a combat turn by turn (Priority: P1)

Initiative rolled with the 3D dice or typed, sorted order, rounds and turns, hit points, conditions, quick add from NPCs, groups of identical monsters.

### User Story 3 - Keep a library of NPCs, monsters and treasures (Priority: P2)

Create, tag, search, import and export creatures with a free stat block of generic fields. Included in backups.

### User Story 4 - Prepare the campaign (Priority: P2)

Campaign and scene notebooks, an ordered or graph story map linking NPCs and places, and a handout screen to show to players.

### User Story 5 - Improvise with generators and ambience (Priority: P3)

Names, encounters, taverns, loot and rumours from editable tables, with a sound ambience per scene.

## Requirements

- **FR-001**: Every tool is an independent module registered in the tool registry with its own theme, animated preview, dark theme, accessible labels and translations.
- **FR-002**: Every tool is usable as a brick of the companion builder.
- **FR-003**: Everything works offline; data is local and part of the backup.
- **FR-004**: No licensed content is shipped; sheets use generic free fields.
- **FR-005**: Dates follow the repository date conventions.

## Delivery

Five lots, one pull request each: shelf, combat tracker, library, campaign notes and handout, generators and ambience.
