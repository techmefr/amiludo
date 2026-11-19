import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/playlist_state.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';

const fadeSteps = 10;

class PlaylistEngine extends ChangeNotifier {
  PlaylistEngine(
    this._output,
    this._blobs, {
    Random? random,
    Future<void> Function(Duration) wait = _realWait,
  }) : _random = random ?? Random(),
       _wait = wait {
    _completions = _output.completed.listen(_onCompleted);
  }

  static Future<void> _realWait(Duration d) => Future.delayed(d);

  final ClipOutput _output;
  final SoundBlobGateway _blobs;
  final Random _random;
  final Future<void> Function(Duration) _wait;
  late final StreamSubscription<String> _completions;
  SoundSet _set = const SoundSet(
    id: '',
    name: '',
    ownerKind: SoundOwnerKind.companion,
    ownerId: '',
  );
  List<String> _order = const [];
  int _index = -1;
  bool _playing = false;
  int _generation = 0;

  bool get playing => _playing;
  String? get currentId =>
      _index >= 0 && _index < _order.length ? _order[_index] : null;

  void load(SoundSet set) {
    final wasPlaying = _playing;
    final id = currentId;
    _set = set;
    _order = _buildOrder(id);
    _index = id == null ? -1 : _order.indexOf(id);
    if (wasPlaying && currentId == null) {
      unawaited(stop());
    } else if (_playing && currentId != null) {
      unawaited(_output.setVolume(currentId!, _volumeOf(currentId!)));
    }
    notifyListeners();
  }

  Future<void> play() async {
    if (_order.isEmpty) return;
    _playing = true;
    if (_index < 0) _index = 0;
    await _start();
  }

  Future<void> pause() async {
    final id = currentId;
    _playing = false;
    _generation++;
    if (id != null) await _output.stop(id);
    notifyListeners();
  }

  Future<void> stop() async {
    await pause();
    _index = -1;
    notifyListeners();
  }

  Future<void> next() async {
    if (_order.isEmpty) return;
    final id = currentId;
    if (id != null) await _output.stop(id);
    _index = (_index + 1) % _order.length;
    _playing = true;
    await _start();
  }

  Future<void> previous() async {
    if (_order.isEmpty) return;
    final id = currentId;
    if (id != null) await _output.stop(id);
    _index = (_index - 1) < 0 ? _order.length - 1 : _index - 1;
    _playing = true;
    await _start();
  }

  Future<void> setVolume(double volume) async {
    _set = _set.copyWith(playlistVolume: volume);
    final id = currentId;
    if (_playing && id != null) await _output.setVolume(id, _volumeOf(id));
  }

  List<String> _buildOrder(String? keep) {
    final ids = [
      for (final id in _set.playlist.entryIds)
        if (_set.entry(id)?.kind == SoundKind.track) id,
    ];
    if (_set.playlist.shuffle) ids.shuffle(_random);
    return ids;
  }

  double _volumeOf(String id) =>
      (_set.entry(id)?.volume ?? 1) * _set.playlistVolume;

  Future<void> _start() async {
    final generation = ++_generation;
    for (var tries = 0; tries < _order.length; tries++) {
      final id = _order[_index];
      final blob = await _blobs.get(id);
      if (generation != _generation) return;
      if (blob != null) {
        final fade = _set.playlist.fadeSeconds;
        final target = _volumeOf(id);
        await _output.play(
          id,
          blob.bytes,
          blob.mimeType,
          volume: fade > 0 ? 0 : target,
          loop: _set.playlist.repeat == PlaylistRepeat.one,
        );
        notifyListeners();
        if (fade > 0) await _fadeIn(id, target, fade, generation);
        return;
      }
      _index = (_index + 1) % _order.length;
    }
    _playing = false;
    notifyListeners();
  }

  Future<void> _fadeIn(
    String id,
    double target,
    double seconds,
    int generation,
  ) async {
    final step = Duration(milliseconds: (seconds * 1000 / fadeSteps).round());
    for (var i = 1; i <= fadeSteps; i++) {
      await _wait(step);
      if (generation != _generation) return;
      await _output.setVolume(id, target * i / fadeSteps);
    }
  }

  void _onCompleted(String id) {
    if (!_playing || id != currentId) return;
    if (_set.playlist.repeat == PlaylistRepeat.one) {
      unawaited(_start());
      return;
    }
    final atEnd = _index + 1 >= _order.length;
    if (atEnd && _set.playlist.repeat == PlaylistRepeat.off) {
      _playing = false;
      _index = -1;
      notifyListeners();
      return;
    }
    _index = (_index + 1) % _order.length;
    unawaited(_start());
  }

  @override
  void dispose() {
    _completions.cancel();
    unawaited(_output.stopAll());
    super.dispose();
  }
}
