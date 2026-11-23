import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';

import 'soundboard_helpers.dart';

void main() {
  test('an empty library adds nothing to the backup', () {
    expect(SoundRig().library.backup(), isEmpty);
  });

  test('backup restores sets and settings, audio comes back missing', () async {
    final source = SoundRig();
    await source.newSet();
    final track = await source.add('Theme', SoundKind.track);
    final fx = await source.add('Roar', SoundKind.effect);
    await source.sets.addToPlaylist(source.set.id, track.id);
    await source.sets.addToSoundboard(source.set.id, fx.id);
    await source.sets.updateEntry(
      source.set.id,
      fx.id,
      (e) => e.copyWith(loop: true, color: 'error'),
    );
    final backup = source.library.backup();

    final target = SoundRig();
    await (target.library.restore(backup))();
    final restored = target.set;
    expect(restored.name, 'Dragons');
    expect(restored.playlist.entryIds, [track.id]);
    expect(restored.soundboard, [fx.id]);
    expect(restored.entry(fx.id)!.loop, isTrue);
    expect(restored.entry(fx.id)!.color, 'error');
    expect(await target.sets.isMissing(restored.entry(track.id)!), isTrue);
  });

  test('a restored missing entry can get its audio back', () async {
    final source = SoundRig();
    await source.newSet();
    final fx = await source.add('Roar', SoundKind.effect);
    final target = SoundRig();
    await (target.library.restore(source.library.backup()))();
    await target.sets.replaceAudio(
      target.set.id,
      fx.id,
      (await source.blobs.get(fx.id))!.bytes,
      'audio/mpeg',
    );
    expect(await target.sets.isMissing(target.set.entry(fx.id)!), isFalse);
  });
}
