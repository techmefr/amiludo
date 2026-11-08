import 'dart:math';
import 'dart:ui';

import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

final Vec3 lightDirection = const Vec3(-0.5, 0.82, 0.38).unit;

double diffuseOf(Vec3 normal) => max(0.0, normal.dot(lightDirection));

Color lit(Color base, Vec3 normal) {
  final sky = 0.5 + 0.5 * normal.y;
  final t = 0.4 + 0.2 * sky + 0.66 * diffuseOf(normal);
  return t <= 1
      ? Color.lerp(const Color(0xFF000000), base, t)!
      : Color.lerp(base, const Color(0xFFFFFFFF), (t - 1) * 0.7)!;
}

({double shine, double gain}) _gloss(DieFinish finish) => switch (finish) {
  DieFinish.gloss => (shine: 48.0, gain: 0.7),
  DieFinish.matte => (shine: 14.0, gain: 0.3),
  DieFinish.soft => (shine: 16.0, gain: 0.2),
  DieFinish.metal => (shine: 28.0, gain: 0.6),
  DieFinish.wood => (shine: 8.0, gain: 0.1),
  DieFinish.crystal => (shine: 70.0, gain: 0.6),
  DieFinish.glass => (shine: 90.0, gain: 0.6),
};

double specularOf(Vec3 normal, Vec3 toEye, DieFinish finish) {
  final half = (lightDirection + toEye).unit;
  final g = _gloss(finish);
  return pow(max(0.0, normal.dot(half)), g.shine).toDouble() * g.gain;
}
