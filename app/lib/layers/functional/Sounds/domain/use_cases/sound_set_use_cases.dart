import 'dart:typed_data';

import 'package:amiludo/layers/functional/Sounds/domain/entities/playlist_state.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';

class SoundSetFull implements Exception {
  const SoundSetFull();
}

class SoundSetUseCases {
  SoundSetUseCases(this._library, this._blobs);

  final SoundLibraryGateway _library;
  final SoundBlobGateway _blobs;

  SoundLibrary get current => _library.current;

  Future<SoundSet> create(
    SoundOwnerKind kind,
    String ownerId,
    String name,
  ) async {
    final set = SoundSet(
      id: newSoundId(),
      name: name,
      ownerKind: kind,
      ownerId: ownerId,
    );
    await _library.save(SoundLibrary([...current.sets, set]));
    return set;
  }

  Future<void> rename(String setId, String name) =>
      _update(setId, (s) => s.copyWith(name: name));

  Future<void> delete(String setId) async {
    final set = _find(setId);
    if (set == null) return;
    for (final entry in set.entries) {
      await _blobs.delete(entry.id);
    }
    await _library.save(
      SoundLibrary([
        for (final s in current.sets)
          if (s.id != setId) s,
      ]),
    );
  }

  Future<SoundEntry> importClip(
    String setId,
    String name,
    Uint8List bytes,
    String mimeType,
    SoundKind kind,
  ) async {
    final set = _find(setId);
    if (set == null) throw StateError('Unknown sound set $setId');
    if (set.isFull) throw const SoundSetFull();
    final entry = SoundEntry(
      id: '${newSoundId()}-${set.entries.length}',
      name: name,
      kind: kind,
      mimeType: mimeType,
      bytesLength: bytes.length,
    );
    await _blobs.put(entry.id, bytes, mimeType);
    await _update(setId, (s) => s.copyWith(entries: [...s.entries, entry]));
    return entry;
  }

  Future<void> replaceAudio(
    String setId,
    String entryId,
    Uint8List bytes,
    String mimeType,
  ) async {
    await _blobs.put(entryId, bytes, mimeType);
    await updateEntry(
      setId,
      entryId,
      (e) => e.copyWith(mimeType: mimeType, bytesLength: bytes.length),
    );
  }

  Future<void> updateEntry(
    String setId,
    String entryId,
    SoundEntry Function(SoundEntry) change,
  ) => _update(
    setId,
    (s) => s.copyWith(
      entries: [for (final e in s.entries) e.id == entryId ? change(e) : e],
    ),
  );

  Future<void> removeEntry(String setId, String entryId) async {
    await _blobs.delete(entryId);
    await _update(
      setId,
      (s) => s.copyWith(
        entries: [
          for (final e in s.entries)
            if (e.id != entryId) e,
        ],
        playlist: s.playlist.copyWith(
          entryIds: [
            for (final id in s.playlist.entryIds)
              if (id != entryId) id,
          ],
        ),
        soundboard: [
          for (final id in s.soundboard)
            if (id != entryId) id,
        ],
      ),
    );
  }

  Future<void> addToPlaylist(String setId, String entryId) => _update(
    setId,
    (s) => s.playlist.entryIds.contains(entryId)
        ? s
        : s.copyWith(
            playlist: s.playlist.copyWith(
              entryIds: [...s.playlist.entryIds, entryId],
            ),
          ),
  );

  Future<void> addToSoundboard(String setId, String entryId) => _update(
    setId,
    (s) => s.soundboard.contains(entryId)
        ? s
        : s.copyWith(soundboard: [...s.soundboard, entryId]),
  );

  Future<void> removeFromPlaylist(String setId, String entryId) => _update(
    setId,
    (s) => s.copyWith(
      playlist: s.playlist.copyWith(
        entryIds: [
          for (final id in s.playlist.entryIds)
            if (id != entryId) id,
        ],
      ),
    ),
  );

  Future<void> removeFromSoundboard(String setId, String entryId) => _update(
    setId,
    (s) => s.copyWith(
      soundboard: [
        for (final id in s.soundboard)
          if (id != entryId) id,
      ],
    ),
  );

  Future<void> reorderPlaylist(String setId, int from, int to) => _update(
    setId,
    (s) => s.copyWith(
      playlist: s.playlist.copyWith(
        entryIds: _moved(s.playlist.entryIds, from, to),
      ),
    ),
  );

  Future<void> reorderSoundboard(String setId, int from, int to) => _update(
    setId,
    (s) => s.copyWith(soundboard: _moved(s.soundboard, from, to)),
  );

  Future<void> configure(
    String setId, {
    bool? shuffle,
    PlaylistRepeat? repeat,
    double? fadeSeconds,
    double? playlistVolume,
    double? soundboardVolume,
  }) => _update(
    setId,
    (s) => s.copyWith(
      playlist: s.playlist.copyWith(
        shuffle: shuffle,
        repeat: repeat,
        fadeSeconds: fadeSeconds,
      ),
      playlistVolume: playlistVolume,
      soundboardVolume: soundboardVolume,
    ),
  );

  Future<bool> isMissing(SoundEntry entry) async =>
      !await _blobs.exists(entry.id);

  SoundSet? _find(String id) {
    for (final s in current.sets) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> _update(String setId, SoundSet Function(SoundSet) change) =>
      _library.save(
        SoundLibrary([
          for (final s in current.sets) s.id == setId ? change(s) : s,
        ]),
      );

  List<String> _moved(List<String> ids, int from, int to) {
    if (from < 0 || from >= ids.length) return ids;
    final list = [...ids];
    final item = list.removeAt(from);
    list.insert(to.clamp(0, list.length), item);
    return list;
  }
}
