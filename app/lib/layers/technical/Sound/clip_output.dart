import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

abstract interface class ClipOutput {
  Stream<String> get completed;
  Future<void> play(
    String id,
    Uint8List bytes,
    String mimeType, {
    required double volume,
    bool loop = false,
  });
  Future<void> setVolume(String id, double volume);
  Future<void> stop(String id);
  Future<void> stopAll();
}

class SilentClipOutput implements ClipOutput {
  const SilentClipOutput();

  @override
  Stream<String> get completed => const Stream.empty();

  @override
  Future<void> play(
    String id,
    Uint8List bytes,
    String mimeType, {
    required double volume,
    bool loop = false,
  }) async {}

  @override
  Future<void> setVolume(String id, double volume) async {}

  @override
  Future<void> stop(String id) async {}

  @override
  Future<void> stopAll() async {}
}

class RecordingClipOutput implements ClipOutput {
  final Map<String, double> playing = {};
  final Set<String> looping = {};
  final List<String> started = [];
  final _completed = StreamController<String>.broadcast(sync: true);

  @override
  Stream<String> get completed => _completed.stream;

  void finish(String id) {
    if (playing.remove(id) != null) {
      looping.remove(id);
      _completed.add(id);
    }
  }

  @override
  Future<void> play(
    String id,
    Uint8List bytes,
    String mimeType, {
    required double volume,
    bool loop = false,
  }) async {
    playing[id] = volume;
    started.add(id);
    loop ? looping.add(id) : looping.remove(id);
  }

  @override
  Future<void> setVolume(String id, double volume) async {
    if (playing.containsKey(id)) playing[id] = volume;
  }

  @override
  Future<void> stop(String id) async {
    playing.remove(id);
    looping.remove(id);
  }

  @override
  Future<void> stopAll() async {
    playing.clear();
    looping.clear();
  }
}

class AudioplayersClipOutput implements ClipOutput {
  final Map<String, AudioPlayer> _players = {};
  final _completed = StreamController<String>.broadcast();

  @override
  Stream<String> get completed => _completed.stream;

  @override
  Future<void> play(
    String id,
    Uint8List bytes,
    String mimeType, {
    required double volume,
    bool loop = false,
  }) async {
    try {
      await stop(id);
      final player = AudioPlayer();
      _players[id] = player;
      player.onPlayerComplete.listen((_) {
        _players.remove(id)?.dispose();
        _completed.add(id);
      });
      await player.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release,
      );
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.play(BytesSource(bytes, mimeType: mimeType));
    } catch (_) {
      _players.remove(id)?.dispose();
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
