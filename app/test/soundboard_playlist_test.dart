import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/playlist_state.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';

import 'soundboard_helpers.dart';

void main() {
  late SoundRig rig;
  late RecordingClipOutput output;
  late List<String> ids;
  late PlaylistEngine engine;

  Future<void> setup({
    bool shuffle = false,
    PlaylistRepeat repeat = PlaylistRepeat.off,
    double fade = 0,
  }) async {
    await rig.sets.configure(
      rig.set.id,
      shuffle: shuffle,
      repeat: repeat,
      fadeSeconds: fade,
    );
    engine.load(rig.set);
  }

  setUp(() async {
    rig = SoundRig();
    output = RecordingClipOutput();
    await rig.newSet();
    ids = [];
    for (final n in ['A', 'B', 'C']) {
      final e = await rig.add(n, SoundKind.track);
      ids.add(e.id);
      await rig.sets.addToPlaylist(rig.set.id, e.id);
    }
    engine = PlaylistEngine(
      output,
      rig.blobs,
      random: Random(1),
      wait: (_) async {},
    );
    engine.load(rig.set);
  });

  tearDown(() => engine.dispose());

  test(
    'plays tracks in order and stops after the last when repeat is off',
    () async {
      await engine.play();
      expect(output.started, [ids[0]]);
      output.finish(ids[0]);
      await Future<void>.delayed(Duration.zero);
      output.finish(ids[1]);
      await Future<void>.delayed(Duration.zero);
      expect(output.started, ids);
      output.finish(ids[2]);
      expect(engine.playing, isFalse);
    },
  );

  test('repeat all wraps to the first track', () async {
    await setup(repeat: PlaylistRepeat.all);
    await engine.play();
    for (final id in ids) {
      output.finish(id);
      await Future<void>.delayed(Duration.zero);
    }
    expect(output.started.last, ids[0]);
    expect(engine.playing, isTrue);
  });

  test('repeat one loops the current track', () async {
    await setup(repeat: PlaylistRepeat.one);
    await engine.play();
    expect(output.looping, contains(ids[0]));
  });

  test('next and previous move through the list', () async {
    await engine.play();
    await engine.next();
    expect(engine.currentId, ids[1]);
    await engine.previous();
    await engine.previous();
    expect(engine.currentId, ids[2]);
  });

  test('pause stops sound and play resumes from the current track', () async {
    await engine.play();
    await engine.next();
    await engine.pause();
    expect(output.playing, isEmpty);
    await engine.play();
    expect(engine.currentId, ids[1]);
    expect(output.playing.keys, [ids[1]]);
  });

  test('shuffle with a seed is deterministic and keeps all tracks', () async {
    await setup(shuffle: true);
    final played = <String>[];
    await engine.play();
    played.add(engine.currentId!);
    for (var i = 0; i < 2; i++) {
      await engine.next();
      played.add(engine.currentId!);
    }
    expect(played.toSet(), ids.toSet());
  });

  test('missing audio is skipped', () async {
    await rig.blobs.delete(ids[0]);
    await engine.play();
    expect(engine.currentId, ids[1]);
    expect(output.started, [ids[1]]);
  });

  test('fade ramps the volume up to the target', () async {
    await setup(fade: 2);
    await engine.play();
    expect(output.playing[ids[0]], closeTo(1, 0.0001));
  });

  test('volume changes apply to the playing track', () async {
    await engine.play();
    await engine.setVolume(0.25);
    expect(output.playing[ids[0]], closeTo(0.25, 0.0001));
  });

  test('stop clears everything', () async {
    await engine.play();
    await engine.stop();
    expect(output.playing, isEmpty);
    expect(engine.currentId, isNull);
  });

  test('effects are never put in the order', () async {
    final fx = await rig.add('Boom', SoundKind.effect);
    await rig.sets.addToPlaylist(rig.set.id, fx.id);
    engine.load(rig.set);
    await engine.play();
    for (var i = 0; i < 5; i++) {
      await engine.next();
      expect(engine.currentId, isNot(fx.id));
    }
  });
}
