import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/die_orient.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/tray_body.dart';

const double _fan = 0.45;

void launchBody(
  TrayBody body,
  SeededRandom rng, {
  required double width,
  required double height,
  required double radius,
  required int index,
  required int count,
  required int sides,
  required double power,
  double aimX = 0,
  double aimY = 0,
}) {
  final n = max(2, sides);
  final round = TrayBody.roundnessFor(n);
  final aimed = aimX != 0 || aimY != 0;
  final base = aimed ? atan2(aimY, aimX) : -pi / 2;
  final heading = base + rng.range(-_fan, _fan);
  final force = rng.range(width, width * 2.2) * power;
  final span = max(0.0, width - radius * 2);
  final row = index % 2;
  body
    ..x = radius + span * (index + 0.5) / max(1, count)
    ..y = max(radius, height - radius - row * radius * 1.2)
    ..vx = cos(heading) * force
    ..vy = sin(heading) * force
    ..angle = rng.range(0, 2 * pi)
    ..spin = rng.range(-14, 14) * power
    ..z = radius * rng.range(0.6, 1.2)
    ..vz = rng.range(300, 520) * (0.5 + 0.5 * power)
    ..phase = rng.range(0, 60)
    ..offset = rng.nextInt(n)
    ..sides = n
    ..roundness = round
    ..tumble = rng.range(14, 24) * (0.4 + 0.6 * power) * (1 + round)
    ..asleep = false
    ..rolling = true
    ..axis = Vec3(
      sin(body.phase),
      cos(body.phase * 0.7 + 1),
      sin(body.offset * 2.1 + 0.3),
    ).unit
    ..rot = turnAbout(const Vec3(0.3, 1, 0.5), body.phase * 1.7);
}
