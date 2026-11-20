# Research: Playlist and soundboard

## Playback interface

- **Decision**: add `ClipOutput` beside `AmbientOutput` instead of extending it.
- **Rationale**: `AmbientOutput` takes generated WAV bytes and always loops; clips need a mime type, one-shot, completion events and per-clip volume.
- **Alternatives considered**: widening `AmbientOutput` (would touch the existing Ambience brick and its tests).

## Audio storage

- **Decision**: audio bytes in a new `SoundBlobs` drift table; set metadata stays a small JSON document.
- **Rationale**: `DocumentStore` writes whole JSON payloads on every change; base64 audio inside it would rewrite megabytes per edit and bloat backups.
- **Alternatives considered**: base64 in the set document (slow, heavy); device file paths (not available on web, break when files move).

## Import

- **Decision**: `file_selector` with an audio type group (mp3, wav, ogg, m4a, aac, flac), 20 MB limit, same pattern as `FileTransfer.openImage`.
- **Alternatives considered**: a new picker package (extra dependency, nothing gained).

## Backup and sharing

- **Decision**: backup and share carry metadata only; entries whose blob is absent show as missing and can be replaced.
- **Rationale**: avoids shipping audio the player may not have rights to and keeps backups small; matches spec User Story 4.

## Campaign attachment

- **Decision**: a set stores an `ownerKind` (companion, campaign) and an `ownerId`; the campaign screen lists the sets whose owner matches. No change to the campaign entity.
