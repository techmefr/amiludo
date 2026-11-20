import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/playlist_state.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';

void main() {
  test('a set survives a JSON round trip', () {
    final set = SoundSet(
      id: 's',
      name: 'Dragons',
      ownerKind: SoundOwnerKind.campaign,
      ownerId: 'c',
      entries: const [
        SoundEntry(id: 'a', name: 'Theme', kind: SoundKind.track, volume: 0.5),
        SoundEntry(id: 'b', name: 'Roar', loop: true, bytesLength: 3),
      ],
      playlist: const PlaylistState(
        entryIds: ['a'],
        shuffle: true,
        repeat: PlaylistRepeat.all,
        fadeSeconds: 2,
      ),
      soundboard: const ['b'],
      playlistVolume: 0.4,
    );
    final back = SoundSet.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonEncode(set.toJson())) as Map),
    );
    expect(jsonEncode(back.toJson()), jsonEncode(set.toJson()));
    expect(back.playlist.repeat, PlaylistRepeat.all);
    expect(back.entries.first.kind, SoundKind.track);
  });

  test('unknown entry fields are kept', () {
    final entry = SoundEntry.fromJson({'id': 'a', 'name': 'x', 'future': 7});
    expect(entry.toJson()['future'], 7);
  });

  test('bad values fall back to safe defaults', () {
    final entry = SoundEntry.fromJson({'id': 'a', 'kind': 'nope', 'volume': 5});
    expect(entry.kind, SoundKind.effect);
    expect(entry.volume, 1);
  });

  test('a set holds at most 100 entries', () {
    final json = {
      'id': 's',
      'entries': [
        for (var i = 0; i < 120; i++) {'id': '$i', 'name': 'n$i'},
      ],
    };
    final set = SoundSet.fromJson(json);
    expect(set.entries, hasLength(maxSoundEntries));
    expect(set.isFull, isTrue);
  });

  test('library lists the sets of an owner', () {
    final library = SoundLibrary([
      const SoundSet(
        id: '1',
        name: 'a',
        ownerKind: SoundOwnerKind.campaign,
        ownerId: 'c',
      ),
      const SoundSet(
        id: '2',
        name: 'b',
        ownerKind: SoundOwnerKind.companion,
        ownerId: 'c',
      ),
    ]);
    expect(library.ownedBy(SoundOwnerKind.campaign, 'c').single.id, '1');
    expect(library.ownedBy(SoundOwnerKind.game, 'c'), isEmpty);
  });
}
