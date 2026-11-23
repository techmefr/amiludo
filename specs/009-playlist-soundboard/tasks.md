# Tasks: Playlist and soundboard for role-playing games

**Input**: Design documents from `/specs/009-playlist-soundboard/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency)
- **[Story]**: user story of the spec (US1 to US4)

## Phase 1: Setup

- [x] T001 Add a `SoundBlobs` table and migrate `StoreDatabase` to schema v2 in `app/lib/layers/technical/Storage/store_database.dart`, regenerate `store_database.g.dart`
- [x] T002 [P] Add the `ClipOutput` interface with `SilentClipOutput` and `RecordingClipOutput` in `app/lib/layers/technical/Sound/clip_output.dart`
- [x] T003 [P] Add the audioplayers implementation `AudioplayersClipOutput` in `app/lib/layers/technical/Sound/audioplayers_clip_output.dart`
- [x] T004 [P] Add the audio file picker with extension and 20 MB checks in `app/lib/layers/technical/Files/audio_clip_import.dart`

## Phase 2: Foundational (blocks all stories)

- [x] T005 Test the v1 to v2 migration keeps stored documents in `app/test/soundboard_storage_test.dart`
- [x] T006 [P] Add entities `SoundSet`, `SoundEntry`, `PlaylistState` with versioned JSON that keeps unknown fields in `app/lib/layers/functional/Sounds/domain/entities/`
- [x] T007 [P] Test JSON round trip and the 100 entries limit against `contracts/sound-set.schema.json` in `app/test/soundboard_model_test.dart`
- [x] T008 Add `SoundBlobGateway` (put, get, delete, exists) and its drift implementation in `app/lib/layers/functional/Sounds/domain/gateways/` and `data/gateways/`
- [x] T009 Add `SoundSetGateway` over `StoredDocument` as a backup section in `app/lib/layers/functional/Sounds/data/gateways/` and register both in `app/lib/dependencies.dart`

## Phase 3: User Story 1 - Prepare a sound set (P1)

**Independent Test**: create a campaign set with two tracks and four effects, restart, find it unchanged.

- [x] T010 [P] [US1] Test import, rename, reorder, recolor and remove, including blob deletion and cascade from set to entries, in `app/test/soundboard_set_use_cases_test.dart`
- [x] T011 [US1] Implement the set use cases in `app/lib/layers/functional/Sounds/domain/use_cases/`
- [x] T012 [US1] Add the set cubit in `app/lib/layers/functional/Sounds/presentation/cubit/`
- [x] T013 [US1] Add the set editor screen (import, rename, recolor, reorder, remove, flag missing or unreadable files) in `app/lib/layers/functional/Sounds/presentation/set_editor.dart`
- [x] T014 [US1] Offer a campaign its own sets from a Sounds tab of the campaign screen (done)

## Phase 4: User Story 2 - Play ambience music (P1)

**Independent Test**: start a three-track playlist, skip, pause, change volume, stop.

- [x] T015 [P] [US2] Test the playlist engine (order, shuffle with seed, repeat off, all and one, skip missing, fade) with `RecordingClipOutput` in `app/test/soundboard_playlist_test.dart`
- [x] T016 [US2] Implement the playlist engine in `app/lib/layers/functional/Sounds/domain/use_cases/playlist_engine.dart`
- [x] T017 [US2] Add the playlist panel (play, pause, next, previous, shuffle, repeat, volume) in `app/lib/layers/functional/Sounds/presentation/playlist_panel.dart`
- [x] T018 [US2] Stop playback when the session ends or the app is left, as configured, in the soundboard tool

## Phase 5: User Story 3 - Trigger sounds (P1)

**Independent Test**: tap each pad quickly in a row; sounds overlap.

- [x] T019 [P] [US3] Test one-shot overlap, loop toggle and stop-all, with the playlist playing in parallel, in `app/test/soundboard_pads_test.dart`
- [x] T020 [US3] Implement the pad behavior in `app/lib/layers/functional/Sounds/domain/use_cases/pad_player.dart`
- [x] T021 [US3] Add the pad grid, stop-all button and the two volume sliders in `app/lib/layers/functional/Sounds/presentation/sound_pad.dart` and `soundboard_tool.dart`

## Phase 6: User Story 4 - Backup and share (P2)

**Independent Test**: export a backup, erase, import; entries return flagged as missing.

- [x] T022 [P] [US4] Test the backup round trip and the missing-audio state in `app/test/soundboard_backup_test.dart`
- [x] T023 [US4] Include the sound sets backup section in export and import (metadata only) and add the replace-audio action on a missing entry

## Phase 7: Integration and polish

- [x] T024 Wire `app/lib/soundboard_tool.dart` with `getIt` and register the route in `app/lib/router.dart`
- [x] T025 Add `soundboard` to `tool_catalog.dart` and `tool_shelves.dart` and as a companion brick
- [x] T026 [P] Translate every text in the seven languages in `app/lib/l10n/`
- [x] T027 [P] Layout tests at 390x844, 844x390, 1280x720 and 1920x1080, keyboard and 200 percent text, in `app/test/soundboard_layout_test.dart`
- [x] T028 [P] Extend `architecture_test.dart` expectations only if the new layer needs them, never weakening them
- [x] T029a Run `flutter analyze` and the full `flutter test` (done: no issues, 1095 tests passed)
- [ ] T029b Check the first-tap audio unlock on the web build by hand
- [x] T030 Add the feature to `docs/FEATURES.md` (F171 and F172, totals updated in the catalog, README and APP-STATUS)

## Dependencies

- Phase 1 then Phase 2 then the stories; US1 first, US2 and US3 can then go in parallel, US4 last.
- T016 and T020 depend on T002 and T008.
- T024 to T030 come after the stories.

## Phase 8: User Story 5 - Playlists on every game, even shared ones (P2)

- [x] T031 [US5] Sound sets on every game companion (owner kind game, scoped to the soundboard brick of that companion)
- [x] T032a [US5] Suggest, accept, reject and cancel flow in a transport-agnostic `SoundShare` (host decides), tested with a three-device in-memory hub
- [x] T032b [US5] Shared tracks panel in the soundboard tool: suggest with confirmation, host accept and refuse list, progress, play, save to the current set
- [x] T033a [US5] Chunked transfer (24 KB chunks), reassembly with size and index checks, progress, cancel, size cap 3 MB, host relay, session-only blobs, save to a set
- [x] T033b [US5] `SoundShareTransport` connected to the lobby: new `app` message type, signed with the room seal in both directions, counters against replay, accepted seats only, tested with a rogue peer
- [~] T034 [US5] Limits measured on a real LAN room over loopback sockets (3 MB intact in 0.7 s unpaced, 3 s at 20 ms pacing, 13 s at 100 ms); LAN pacing set to 20 ms. The remote relay and a Wi-Fi network are not measured, remote keeps 100 ms and the 3 MB cap stays a prudent value
- [x] T035 [US5] Sender confirmation required before a suggestion, received audio session-only unless saved (enforced and tested in `SoundShare`; the confirmation dialog belongs to T032b)
