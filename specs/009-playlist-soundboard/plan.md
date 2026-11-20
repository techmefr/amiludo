# Implementation Plan: Playlist and soundboard for role-playing games

**Branch**: `feat/playlist-soundboard` | **Date**: 2026-11-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/009-playlist-soundboard/spec.md`

## Summary

A new `soundboard` brick lets a game master import their own audio files, group them in a sound set (playlist plus soundboard) attached to a companion or a campaign, and play them in session. Playback sits behind a new technical interface next to `AmbientOutput`; the generated Ambience brick is untouched.

## Technical Context

**Language/Version**: Dart ^3.13.7, Flutter

**Primary Dependencies**: audioplayers (already used), file_selector (already used), drift, get_it, flutter_bloc, go_router

**Storage**: sound set metadata as a `StoredDocument` (JSON, in backup); audio bytes in a new `SoundBlobs` drift table keyed by entry id (schema v2)

**Testing**: flutter_test, `RecordingClipOutput` test double, drift in-memory executor

**Target Platform**: Android, iOS, web (offline-capable), desktop

**Project Type**: mobile-app (Flutter) with OSDD layers

**Performance Goals**: soundboard tap audible under 200 ms; list stays smooth with 100 entries

**Constraints**: files under 200 lines, no comments, every text in the seven languages, design tokens only, existing tests only extended, technical never imports functional

**Scale/Scope**: a set holds up to 100 entries; one file up to 20 MB

## Constitution Check

The constitution file is still the empty template, so no gate applies. The repository conventions listed in Constraints are applied instead (also recorded in `specs/005-companion-builder/plan.md`).

## Project Structure

### Documentation (this feature)

```text
specs/009-playlist-soundboard/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── sound-set.schema.json
└── tasks.md
```

### Source Code (repository root)

```text
app/lib/layers/technical/Sound/
├── sound_output.dart            (existing, untouched)
├── clip_output.dart             (new interface: play, loop, volume, stop, stopAll, completion)
└── audio_clip_import.dart       (new: pick audio file, size limit, format check)
app/lib/layers/technical/Storage/
└── store_database.dart          (SoundBlobs table, migration to v2)
app/lib/layers/functional/Sounds/
├── domain/entities/             (sound_set, sound_entry, playlist_state)
├── domain/gateways/             (sound_set_gateway, sound_blob_gateway)
├── domain/use_cases/            (import, rename, reorder, remove, next track)
├── data/gateways/
└── presentation/                (soundboard_tool, playlist_panel, sound_pad, set_editor, cubit/)
app/lib/soundboard_tool.dart     (wiring with getIt, like ambience_tool.dart)
app/test/                        (soundboard_*_test.dart)
```

**Structure Decision**: a new functional layer `Sounds`, reusing the Companion brick registration and the tool catalog; the playback interface lives in technical `Sound`.

## Phases

### Phase 0: research

See [research.md](research.md).

### Phase 1: design

See [data-model.md](data-model.md), [contracts/sound-set.schema.json](contracts/sound-set.schema.json) and [quickstart.md](quickstart.md).

## Lots

1. **Storage**: `SoundBlobs` table, migration test, blob gateway.
2. **Model and persistence**: entities, versioned JSON, set gateway through `StoredDocument`, backup section.
3. **Playback**: `ClipOutput`, audioplayers and recording implementations, playlist engine (order, shuffle, loop, fade).
4. **Import**: audio picker with size and format checks, flagging unreadable or missing files.
5. **Soundboard UI**: pads, one-shot and loop modes, stop-all, independent volumes.
6. **Playlist UI and set editor**: playlist panel, reorder, rename, recolor, remove.
7. **Integration**: brick registration, tool catalog and shelf, campaign attachment, i18n in seven languages, backup round trip.

## Risks

- Browsers block audio until a user gesture: the first tap must unlock playback; checked by hand on the deployed web build.
- Large blobs in drift on web (IndexedDB): enforce the 20 MB limit and test import of a large file.
- Background playback differs per platform: the behavior is configurable and tested through the recording output only; real devices verified by hand.
- Layout tests at 390x844, 844x390, 1280x720 and 1920x1080.

## Lot 8: shared playlists (User Story 5)

- Transport: the existing room channel carries JSON only. Audio is split into numbered base64 chunks of about 32 KB (LAN messages are capped at 64 KB), sent with a clip id, index and total, and reassembled on the receiver; a missing chunk or a cancel drops the clip and leaves the room untouched.
- Roles: players send suggestions (title and clip id), the host accepts, reorders or removes; only accepted tracks are transferred to the others.
- Limits: a per-clip size cap and a send rate that fits the remote relay; both are measured on real rooms (T034), not guessed.
- Storage: received audio goes into the blob table flagged as session-only and is purged at session end unless the player saves it.

### Lobby security notes

- Room messages of type `app` are authenticated, not encrypted: they carry the room signature and a counter, exactly like the lobby state. Anyone who has the room link can read them, as for every other room message.
- A guest message also carries the seat id; the host only accepts it from an accepted seat with a counter above the last one seen. A room member knows the room secret and can therefore impersonate another seat; the host accepting or refusing each track, the size cap and the per-player limit are the safety net.
- A link without the room secret cannot send or receive audio.

