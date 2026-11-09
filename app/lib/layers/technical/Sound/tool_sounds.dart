import 'dart:typed_data';

import 'package:amiludo/layers/technical/Sound/sound_output.dart';
import 'package:amiludo/layers/technical/Sound/wav_synth.dart';

enum ToolSoundKind { thud, knock, rustle, snap, chime, tick }

abstract final class ToolSounds {
  static bool enabled = false;
  static double volume = .5;
  static SoundOutput output = AudioplayersSoundOutput();
  static final Map<ToolSoundKind, Uint8List> _cache = {};

  static Uint8List wav(ToolSoundKind kind) => _cache.putIfAbsent(
    kind,
    () => switch (kind) {
      ToolSoundKind.thud => clatter(
        frequency: 160,
        decay: 40,
        seconds: .14,
        seed: 31,
        peak: .8,
      ),
      ToolSoundKind.knock => clatter(
        frequency: 340,
        decay: 80,
        seconds: .09,
        seed: 32,
        peak: .7,
      ),
      ToolSoundKind.rustle => whoosh(seconds: .18, seed: 33),
      ToolSoundKind.snap => clatter(
        frequency: 1800,
        decay: 200,
        seconds: .05,
        seed: 34,
        peak: .6,
      ),
      ToolSoundKind.chime => clatter(
        frequency: 1320,
        decay: 12,
        seconds: .45,
        seed: 35,
        peak: .5,
      ),
      ToolSoundKind.tick => clatter(
        frequency: 1500,
        decay: 220,
        seconds: .04,
        seed: 36,
        peak: .5,
      ),
    },
  );

  static Future<void> play(ToolSoundKind kind) async {
    if (!enabled) return;
    await output.play(wav(kind), volume);
  }
}
