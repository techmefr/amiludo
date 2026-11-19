import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';

import 'soundboard_helpers.dart';

void main() {
  late SoundRig rig;
  setUp(() async {
    rig = SoundRig();
    await rig.newSet();
  });

  test('import stores the blob and the entry', () async {
    final entry = await rig.add('Roar', SoundKind.effect);
    expect(rig.set.entries.single.name, 'Roar');
    expect(rig.set.entries.single.bytesLength, 3);
    expect(await rig.blobs.exists(entry.id), isTrue);
  });

  test('rename, recolor and volume keep the other entries', () async {
    final a = await rig.add('A', SoundKind.track);
    final b = await rig.add('B', SoundKind.effect);
    await rig.sets.updateEntry(
      rig.set.id,
      a.id,
      (e) => e.copyWith(name: 'A2', color: 'danger', volume: 0.3),
    );
    expect(rig.set.entry(a.id)!.name, 'A2');
    expect(rig.set.entry(a.id)!.color, 'danger');
    expect(rig.set.entry(b.id)!.name, 'B');
  });

  test('removing an entry cleans playlist, soundboard and blob', () async {
    final a = await rig.add('A', SoundKind.track);
    await rig.sets.addToPlaylist(rig.set.id, a.id);
    await rig.sets.addToSoundboard(rig.set.id, a.id);
    await rig.sets.removeEntry(rig.set.id, a.id);
    expect(rig.set.entries, isEmpty);
    expect(rig.set.playlist.entryIds, isEmpty);
    expect(rig.set.soundboard, isEmpty);
    expect(await rig.blobs.exists(a.id), isFalse);
  });

  test('deleting a set deletes the blobs of its entries', () async {
    final a = await rig.add('A', SoundKind.track);
    await rig.sets.delete(rig.set.id);
    expect(rig.library.current.sets, isEmpty);
    expect(await rig.blobs.exists(a.id), isFalse);
  });

  test('reordering the playlist and the soundboard', () async {
    final a = await rig.add('A', SoundKind.track);
    final b = await rig.add('B', SoundKind.track);
    final c = await rig.add('C', SoundKind.effect);
    final d = await rig.add('D', SoundKind.effect);
    for (final e in [a, b]) {
      await rig.sets.addToPlaylist(rig.set.id, e.id);
    }
    for (final e in [c, d]) {
      await rig.sets.addToSoundboard(rig.set.id, e.id);
    }
    await rig.sets.reorderPlaylist(rig.set.id, 0, 1);
    await rig.sets.reorderSoundboard(rig.set.id, 1, 0);
    expect(rig.set.playlist.entryIds, [b.id, a.id]);
    expect(rig.set.soundboard, [d.id, c.id]);
  });

  test('adding the same entry twice does not duplicate it', () async {
    final a = await rig.add('A', SoundKind.track);
    await rig.sets.addToPlaylist(rig.set.id, a.id);
    await rig.sets.addToPlaylist(rig.set.id, a.id);
    expect(rig.set.playlist.entryIds, hasLength(1));
  });

  test('a full set refuses another import', () async {
    for (var i = 0; i < 100; i++) {
      await rig.add('n$i', SoundKind.effect);
    }
    expect(
      () => rig.sets.importClip(
        rig.set.id,
        'one more',
        Uint8List.fromList([1]),
        'audio/mpeg',
        SoundKind.effect,
      ),
      throwsA(isA<SoundSetFull>()),
    );
  });

  test('a missing blob is flagged and replaceable', () async {
    final a = await rig.add('A', SoundKind.effect);
    await rig.blobs.delete(a.id);
    expect(await rig.sets.isMissing(rig.set.entry(a.id)!), isTrue);
    await rig.sets.replaceAudio(
      rig.set.id,
      a.id,
      Uint8List.fromList([7, 7]),
      'audio/wav',
    );
    expect(await rig.sets.isMissing(rig.set.entry(a.id)!), isFalse);
    expect(rig.set.entry(a.id)!.bytesLength, 2);
  });

  test('sets persist through a fresh gateway', () async {
    await rig.add('A', SoundKind.effect);
    await rig.library.save(rig.library.current);
    final fresh = await rig.database.readDocument('sounds');
    expect(fresh, contains('Dragons'));
  });
}
