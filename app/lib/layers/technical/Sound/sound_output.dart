import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

abstract interface class SoundOutput {
  Future<void> play(Uint8List wav, double volume);
}

class SilentSoundOutput implements SoundOutput {
  const SilentSoundOutput();

  @override
  Future<void> play(Uint8List wav, double volume) async {}
}

class RecordingSoundOutput implements SoundOutput {
  final List<(Uint8List, double)> played = [];

  @override
  Future<void> play(Uint8List wav, double volume) async =>
      played.add((wav, volume));
}

class AudioplayersSoundOutput implements SoundOutput {
  static const int _voices = 6;

  final List<AudioPlayer> _players = [];
  int _next = 0;

  @override
  Future<void> play(Uint8List wav, double volume) async {
    try {
      if (_players.length < _voices) {
        _players.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      }
      final player = _players[_next++ % _players.length];
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.play(BytesSource(wav, mimeType: 'audio/wav'));
    } catch (_) {
      return;
    }
  }
}
