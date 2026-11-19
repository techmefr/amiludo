import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_set.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/technical/Sound/clip_output.dart';

class PadPlayer extends ChangeNotifier {
  PadPlayer(this._output, this._blobs) {
    _completions = _output.completed.listen((id) {
      if (id.startsWith(_padPrefix) &&
          _active.remove(id.substring(_padPrefix.length))) {
        notifyListeners();
      }
    });
  }

  final ClipOutput _output;
  final SoundBlobGateway _blobs;
  late final StreamSubscription<String> _completions;
  final Set<String> _active = {};
  double _volume = 1;

  bool isActive(String entryId) => _active.contains(entryId);

  static const _padPrefix = 'pad:';

  String _padId(String entryId) => '$_padPrefix$entryId';

  void setVolume(double volume) {
    _volume = volume;
    for (final id in _active) {
      unawaited(_output.setVolume(_padId(id), volume));
    }
  }

  Future<void> trigger(SoundSet set, SoundEntry entry) async {
    _volume = set.soundboardVolume;
    final key = _padId(entry.id);
    if (entry.loop && _active.contains(entry.id)) {
      _active.remove(entry.id);
      await _output.stop(key);
      notifyListeners();
      return;
    }
    final blob = await _blobs.get(entry.id);
    if (blob == null) return;
    _active.add(entry.id);
    await _output.play(
      key,
      blob.bytes,
      blob.mimeType,
      volume: entry.volume * _volume,
      loop: entry.loop,
    );
    notifyListeners();
  }

  Future<void> stopAll() async {
    for (final id in _active.toList()) {
      await _output.stop(_padId(id));
    }
    _active.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _completions.cancel();
    super.dispose();
  }
}
