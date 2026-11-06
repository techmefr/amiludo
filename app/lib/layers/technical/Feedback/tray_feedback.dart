import 'package:flutter/services.dart';

import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Physics/tray_body.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';
import 'package:amiludo/layers/technical/Sound/tray_sound_bank.dart';

class TrayFeedback {
  TrayFeedback({
    this.output = const SilentSoundOutput(),
    this.sound = false,
    this.haptics = false,
    this.material = SurfaceMaterial.wood,
    this.clock = DateTime.now,
  });

  final SoundOutput output;
  final bool sound, haptics;
  final DateTime Function() clock;
  SurfaceMaterial material;
  final Map<SurfaceMaterial, TraySoundBank> _banks = {};
  DateTime _lastSound = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastHaptic = DateTime.fromMillisecondsSinceEpoch(0);
  int _counter = 0;

  TraySoundBank get _bank =>
      _banks.putIfAbsent(material, () => TraySoundBank(material));

  void impact(TrayImpact hit) {
    final now = clock();
    if (sound && now.difference(_lastSound).inMilliseconds >= 30) {
      _lastSound = now;
      final volume = (hit.speed / 900).clamp(0.15, 1.0) * material.loudness;
      final wav = hit.speed < 120
          ? _bank.rattle
          : _bank.impact(hit.speed, _counter++);
      output.play(wav, volume);
    }
    if (haptics &&
        hit.speed > 220 &&
        now.difference(_lastHaptic).inMilliseconds >= 90) {
      _lastHaptic = now;
      _vibrate(HapticFeedback.lightImpact);
    }
  }

  void thrown(double power) {
    if (sound) output.play(_bank.whooshSound, (power * 0.8).clamp(0.2, 1.0));
  }

  void settled() {
    if (sound) output.play(_bank.tick, 0.7 * material.loudness);
    if (haptics) _vibrate(HapticFeedback.mediumImpact);
  }

  Future<void> _vibrate(Future<void> Function() call) async {
    try {
      await call();
    } catch (_) {
      return;
    }
  }
}
