# Data Model: Playlist and soundboard

## SoundSet

| Field | Type | Notes |
|---|---|---|
| id | string | unique |
| name | string | |
| ownerKind | `companion` or `campaign` | |
| ownerId | string | companion or campaign id |
| entries | SoundEntry list | up to 100 |
| playlist | PlaylistState | |
| soundboard | string list | entry ids in pad order |
| playlistVolume, soundboardVolume | number 0..1 | independent |

## SoundEntry

| Field | Type | Notes |
|---|---|---|
| id | string | also the blob key |
| name | string | |
| kind | `track` or `effect` | decides where it can be placed |
| color | string | design token name |
| volume | number 0..1 | |
| loop | boolean | effect pads only |
| mimeType | string | |
| bytesLength | integer | detects missing or corrupt blobs |

## PlaylistState

| Field | Type | Notes |
|---|---|---|
| entryIds | string list | ordered |
| shuffle | boolean | |
| repeat | `off`, `all`, `one` | |
| fadeSeconds | number | 0 disables the fade |

Runtime state (current index, playing, position) is never persisted.

## SoundBlob (drift table `SoundBlobs`)

`id` (text, key), `bytes` (blob), `mimeType` (text).

## Rules

- Removing an entry removes it from the playlist and the soundboard and deletes its blob.
- Removing a set deletes the blobs of its entries.
- An entry without a blob is `missing` and is skipped by the playlist.
- The JSON carries `version`; unknown fields are kept.
