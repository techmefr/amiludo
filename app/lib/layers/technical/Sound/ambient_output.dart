import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

abstract interface class AmbientOutput {
  Future<void> start(String id, Uint8List wav, double volume);
  Future<void> setVolume(String id, double volume);
  Future<void> stop(String id);
  Future<void> stopAll();
}

class SilentAmbientOutput implements AmbientOutput {
  const SilentAmbientOutput();

  @override
  Future<void> start(String id, Uint8List wav, double volume) async {}

  @override
  Future<void> setVolume(String id, double volume) async {}

  @override
  Future<void> stop(String id) async {}

  @override
  Future<void> stopAll() async {}
}

class RecordingAmbientOutput implements AmbientOutput {
  final Map<String, double> playing = {};

  @override
  Future<void> start(String id, Uint8List wav, double volume) async =>
      playing[id] = volume;

  @override
  Future<void> setVolume(String id, double volume) async {
    if (playing.containsKey(id)) playing[id] = volume;
  }

  @override
  Future<void> stop(String id) async => playing.remove(id);

  @override
  Future<void> stopAll() async => playing.clear();
}

class AudioplayersAmbientOutput implements AmbientOutput {
  final Map<String, AudioPlayer> _players = {};

  @override
  Future<void> start(String id, Uint8List wav, double volume) async {
    try {
      final player = _players.putIfAbsent(id, AudioPlayer.new);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.play(BytesSource(wav, mimeType: 'audio/wav'));
    } catch (_) {
      return;
    }
  }

  @override
  Future<void> setVolume(String id, double volume) async {
    try {
      await _players[id]?.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {
      return;
    }
  }

  @override
  Future<void> stop(String id) async {
    try {
      await _players.remove(id)?.dispose();
    } catch (_) {
      return;
    }
  }

  @override
  Future<void> stopAll() async {
    for (final id in _players.keys.toList()) {
      await stop(id);
    }
  }
}
