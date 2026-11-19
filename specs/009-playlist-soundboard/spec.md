# Feature Specification: Playlist and soundboard for role-playing games

**Feature Branch**: `feat/playlist-soundboard`

**Created**: 2026-11-19

**Status**: Draft

**Input**: User description: "In the game builder, add a playlist and soundboard part. For role-playing games, hear ambience music and add sounds depending on one's game or the campaign being prepared."

## Existing building blocks reused

- `AmbienceTool` and `AmbientOutput` (start, volume, stop, stopAll, silent and recording test doubles) for playback.
- The companion builder bricks, the tool catalog and shelves, the router registry.
- Campaigns of the notebook (campaign tabs) to attach a sound set to a campaign.
- Document store, `StoredDocument` and `BackupSection` for persistence and backup.
- Immersive page layout and design tokens.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Prepare a sound set for my game or campaign (Priority: P1)

A game master builds a sound set: a playlist of ambience tracks and a soundboard of short sounds, each named and set up. The set belongs to a game companion or to a campaign.

**Independent Test**: create a set for a campaign with two playlist tracks and four soundboard buttons, close the app, reopen it, and find the set unchanged.

**Acceptance Scenarios**:

1. **Given** an empty set, **When** the player imports audio files, **Then** each file appears as a named entry that can be put in the playlist or on the soundboard.
2. **Given** a set, **When** the player renames, reorders, recolors or removes an entry, **Then** the other entries keep their settings.
3. **Given** a set attached to a campaign, **When** that campaign is opened, **Then** its set is offered; a game companion can hold its own set.

---

### User Story 2 - Play ambience music during a session (Priority: P1)

The game master starts a playlist: tracks play in order or shuffled, can loop, fade between tracks, and have a volume set apart from the soundboard.

**Independent Test**: start a three-track playlist, skip, pause, change the volume and stop it.

**Acceptance Scenarios**:

1. **Given** a playlist, **When** a track ends, **Then** the next one starts (or the list loops, or stops, as configured).
2. **Given** a playing playlist, **When** a soundboard sound is triggered, **Then** both are heard and each keeps its own volume.
3. **Given** a playing playlist, **When** the app goes to the background or the session ends, **Then** playback follows the configured behavior and never continues silently forever.

---

### User Story 3 - Trigger sounds at the right moment (Priority: P1)

The soundboard shows large buttons. A tap plays the sound once; a sound can be set to loop until tapped again, or to stop others.

**Independent Test**: tap each button quickly in a row; sounds overlap without freezing the screen.

**Acceptance Scenarios**:

1. **Given** a one-shot button, **When** tapped, **Then** it plays once and can be retriggered at once.
2. **Given** a looping button, **When** tapped twice, **Then** it starts then stops.
3. **Given** a stop-all control, **When** used, **Then** every sound and the playlist stop.

---

### User Story 4 - Share a sound set (Priority: P2)

A set can be backed up with the rest of the player's data. Sharing the setup (names, order, settings) does not include audio files the player does not own the rights to.

**Acceptance Scenarios**:

1. **Given** a backup, **When** restored, **Then** the sets return with their entries and settings.
2. **Given** a shared setup without audio, **When** opened, **Then** each missing file is shown as missing and can be replaced.

---

### User Story 5 - Playlists on every game, even shared ones (Priority: P2)

Any game companion can hold its own sound sets, not only campaigns. A playlist can be collaborative: the other players of the table add tracks to it, and the game master keeps control of what plays.

**Why this priority**: it extends the same sets to board and card games and to evenings, but depends on rooms and sharing.

**Independent Test**: on a game companion, create a playlist, invite two players in the room, each adds a track; all three tracks appear for everyone and the host plays them.

**Acceptance Scenarios**:

1. **Given** a game companion, **When** a sound set is created from it, **Then** it is listed on that game and nowhere else.
2. **Given** a collaborative playlist in a room, **When** a player adds a track, **Then** the host and the other players see it and the host can accept, reorder or remove it.
3. **Given** a player without the audio file, **When** a shared track is played on their device, **Then** it is shown as missing and never blocks the others.

[NEEDS CLARIFICATION: do contributed tracks carry their audio to other devices, or only a title and a link the host resolves from their own library?]

---

### Edge Cases

- An imported file is unreadable or in an unsupported format: the entry is flagged, nothing else breaks.
- A file is removed from the device after import: the entry shows as missing.
- Very large files or many entries: import and list stay responsive.
- No audio output available: the screen still works and says so.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The player MUST be able to create, rename and delete sound sets, attached to a game companion or to a campaign.
- **FR-002**: The player MUST be able to import their own audio files; the app MUST NOT download or bundle third-party audio.
- **FR-003**: A set MUST hold a playlist (ordered tracks) and a soundboard (buttons) built from imported entries.
- **FR-004**: The playlist MUST support play, pause, next, previous, shuffle, loop and a fade between tracks.
- **FR-005**: Playlist and soundboard MUST have independent volumes, with a stop-all control.
- **FR-006**: A soundboard button MUST support one-shot and loop modes and overlapping playback.
- **FR-007**: Sets MUST persist and be included in backup and restore.
- **FR-008**: The part MUST be reachable as a brick of the companion builder and from a campaign.
- **FR-009**: All texts MUST be translated (i18n) and the screens MUST follow the design tokens and accessibility rules.
- **FR-010**: The existing Ambience brick MUST keep working unchanged.

### Key Entities

- **SoundSet**: name, owner (companion or campaign), playlist, soundboard.
- **SoundEntry**: name, source file reference, color, volume, kind (track or effect), loop flag.
- **PlaylistState**: ordered entry ids, current index, shuffle, loop, fade.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A game master prepares a set of 10 entries in under 3 minutes.
- **SC-002**: A soundboard tap is heard in under 200 ms.
- **SC-003**: Restoring a backup returns every set with all its settings.

## Assumptions

- Sounds come from the player's own files; supported formats are the ones the audio plugin already handles.
- This is a new brick next to Ambience, which stays the generated-ambience tool.
- Streaming services and online catalogs are out of scope.
