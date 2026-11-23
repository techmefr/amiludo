import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/pad_player.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/playlist_engine.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';

import 'soundboard_helpers.dart';

void main() {
  late SoundRig rig;
  late RecordingClipOutput output;
  late PadPlayer pads;

  setUp(() async {
    rig = SoundRig();
    output = RecordingClipOutput();
    pads = PadPlayer(output, rig.blobs);
    await rig.newSet();
  });

  test('a one-shot pad plays and can be retriggered at once', () async {
    final e = await rig.add('Boom', SoundKind.effect);
    await pads.trigger(rig.set, rig.set.entry(e.id)!);
    await pads.trigger(rig.set, rig.set.entry(e.id)!);
    expect(output.started, hasLength(2));
  });

  test('different pads overlap', () async {
    final a = await rig.add('A', SoundKind.effect);
    final b = await rig.add('B', SoundKind.effect);
    await pads.trigger(rig.set, rig.set.entry(a.id)!);
    await pads.trigger(rig.set, rig.set.entry(b.id)!);
    expect(output.playing, hasLength(2));
  });

  test('a loop pad starts then stops on the second tap', () async {
    final e = await rig.add('Rain', SoundKind.effect);
    await rig.sets.updateEntry(rig.set.id, e.id, (x) => x.copyWith(loop: true));
    final entry = rig.set.entry(e.id)!;
    await pads.trigger(rig.set, entry);
    expect(pads.isActive(e.id), isTrue);
    expect(output.looping, isNotEmpty);
    await pads.trigger(rig.set, entry);
    expect(pads.isActive(e.id), isFalse);
    expect(output.playing, isEmpty);
  });

  test('stop all silences pads and the playlist', () async {
    final track = await rig.add('Theme', SoundKind.track);
    await rig.sets.addToPlaylist(rig.set.id, track.id);
    final fx = await rig.add('Boom', SoundKind.effect);
    final engine = PlaylistEngine(output, rig.blobs, wait: (_) async {});
    engine.load(rig.set);
    await engine.play();
    await pads.trigger(rig.set, rig.set.entry(fx.id)!);
    expect(output.playing, hasLength(2));
    await engine.stop();
    await pads.stopAll();
    expect(output.playing, isEmpty);
    engine.dispose();
  });

  test('pad and playlist volumes are independent', () async {
    final track = await rig.add('Theme', SoundKind.track);
    await rig.sets.addToPlaylist(rig.set.id, track.id);
    final fx = await rig.add('Boom', SoundKind.effect);
    await rig.sets.configure(
      rig.set.id,
      playlistVolume: 0.2,
      soundboardVolume: 0.8,
    );
    final engine = PlaylistEngine(output, rig.blobs, wait: (_) async {});
    engine.load(rig.set);
    await engine.play();
    await pads.trigger(rig.set, rig.set.entry(fx.id)!);
    expect(output.playing[track.id], closeTo(0.2, 0.0001));
    expect(output.playing['pad:${fx.id}'], closeTo(0.8, 0.0001));
    engine.dispose();
  });

  test('a pad with missing audio stays silent', () async {
    final e = await rig.add('Gone', SoundKind.effect);
    await rig.blobs.delete(e.id);
    await pads.trigger(rig.set, rig.set.entry(e.id)!);
    expect(output.started, isEmpty);
    expect(pads.isActive(e.id), isFalse);
  });

  test('a finished one-shot is no longer active', () async {
    final e = await rig.add('Boom', SoundKind.effect);
    await pads.trigger(rig.set, rig.set.entry(e.id)!);
    output.finish('pad:${e.id}');
    expect(pads.isActive(e.id), isFalse);
  });
}
