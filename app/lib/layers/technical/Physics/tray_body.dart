import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/die_orient.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

enum ImpactKind { wall, floor, die }

class TrayImpact {
  const TrayImpact(this.kind, this.speed);

  final ImpactKind kind;
  final double speed;
}

class TrayBody {
  TrayBody({
    this.x = 0,
    this.y = 0,
    this.vx = 0,
    this.vy = 0,
    this.angle = 0,
    this.spin = 0,
  });

  double x, y, vx, vy, angle, spin;
  double z = 0, vz = 0, phase = 0, tumble = 0, roundness = 0;
  int offset = 0, sides = 6;
  bool asleep = true, rolling = false;
  Mat3 rot = Mat3.identity;
  Vec3 axis = const Vec3(0, 1, 0);

  static double roundnessFor(int sides) => ((sides - 6) / 40).clamp(0.0, 1.0);

  double get speed => sqrt(vx * vx + vy * vy);

  int get face => (phase.floor() + offset) % sides + 1;

  double get spinX => sin(phase * pi) * min(1.0, tumble / 5);

  double get spinY => cos(phase * pi) * min(1.0, tumble / 5);

  double get flipX => spinX * (1 - roundness);

  double get flipY => spinY * (1 - roundness);

  double get settled => 1 - min(1.0, tumble / 5);

  void spinStep(double dt) {
    if (tumble > 0) rot = turnAbout(axis, tumble * 0.55 * dt) * rot;
  }

  void kick() {
    final heading = Vec3(vy, -vx, 0);
    if (heading.length > 1) axis = (axis + heading.unit * 0.9).unit;
  }

  void sleep() {
    vx = 0;
    vy = 0;
    vz = 0;
    z = 0;
    spin = 0;
    tumble = 0;
    asleep = true;
    rolling = false;
  }

  TrayBody copy() =>
      TrayBody(x: x, y: y, vx: vx, vy: vy, angle: angle, spin: spin)
        ..z = z
        ..vz = vz
        ..phase = phase
        ..tumble = tumble
        ..roundness = roundness
        ..offset = offset
        ..sides = sides
        ..asleep = asleep
        ..rolling = rolling
        ..rot = rot
        ..axis = axis;
}
