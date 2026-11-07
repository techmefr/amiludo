import 'dart:typed_data';

import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Sound/wav_synth.dart';

class TraySoundBank {
  TraySoundBank(this.material)
    : impacts = [
        for (var level = 0; level < 3; level++)
          [for (var v = 0; v < 3; v++) _impact(material, level, v)],
      ],
      rattle = clatter(
        frequency: 700 * material.pitch,
        decay: 90,
        seconds: 0.09,
        seed: 900,
        peak: 0.5,
      ),
      tick = clatter(
        frequency: 1500 * material.pitch,
        decay: 220,
        seconds: 0.04,
        seed: 901,
        peak: 0.6,
      ),
      whooshSound = whoosh(seconds: 0.26, seed: 902);

  final SurfaceMaterial material;
  final List<List<Uint8List>> impacts;
  final Uint8List rattle, tick, whooshSound;

  static Uint8List _impact(SurfaceMaterial m, int level, int variant) =>
      clatter(
        frequency: (520 + level * 180 + variant * 70) * m.pitch,
        decay: 70 + 90 * (1 - m.ring) + level * 10,
        seconds: 0.06 + 0.12 * m.ring + 0.03 * level,
        seed: level * 10 + variant,
        peak: 0.55 + 0.2 * level,
      );

  static int levelOf(double speed) => speed < 250 ? 0 : (speed < 600 ? 1 : 2);

  Uint8List impact(double speed, int counter) =>
      impacts[levelOf(speed)][counter % 3];
}
