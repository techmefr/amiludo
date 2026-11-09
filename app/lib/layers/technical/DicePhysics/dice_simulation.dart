import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/convex_shape.dart';
import 'package:amiludo/layers/technical/DicePhysics/dice_world.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';
import 'package:amiludo/layers/technical/DicePhysics/quat.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

class DiceSimulation {
  DiceSimulation({
    required this.sides,
    required this.seed,
    this.power = 1,
    this.aim = const Vec3(0, 0, -1),
    double halfWidth = 6,
    double halfDepth = 4.2,
  }) : world = DiceWorld(halfWidth: halfWidth, halfDepth: halfDepth) {
    _launch();
  }

  static const double maxSeconds = 14;

  final List<int> sides;
  final int seed;
  final double power;
  final Vec3 aim;
  final DiceWorld world;
  double _carry = 0, _elapsed = 0;

  bool get settled => world.settled;

  List<DieBody> get bodies => world.bodies;

  List<int> get values => [for (final b in bodies) b.value];

  static List<int> roll(
    List<int> sides,
    int seed, {
    double power = 1,
    Vec3 aim = const Vec3(0, 0, -1),
    double halfWidth = 6,
    double halfDepth = 4.2,
  }) {
    final run = DiceSimulation(
      sides: sides,
      seed: seed,
      power: power,
      aim: aim,
      halfWidth: halfWidth,
      halfDepth: halfDepth,
    );
    run.settle();
    return run.values;
  }

  void tilt(Vec3 acceleration) {
    world.tilt(acceleration);
    _elapsed = 0;
  }

  void advance(double dt) {
    _carry += min(dt, 0.1);
    while (_carry >= DiceWorld.step && !settled) {
      world.advance();
      _carry -= DiceWorld.step;
      _elapsed += DiceWorld.step;
      if (_elapsed > maxSeconds && !world.leaning) world.freeze();
    }
    if (settled) _carry = 0;
  }

  void settle() {
    while (!settled) {
      world.advance();
      _elapsed += DiceWorld.step;
      if (_elapsed > maxSeconds) world.freeze();
    }
  }

  void _launch() {
    final rng = SeededRandom(seed);
    final p = power.clamp(0.2, 1.5);
    final flat = Vec3(aim.x, 0, aim.z).unit;
    final heading = flat.length == 0 ? const Vec3(0, 0, -1) : flat;
    final perRow = max(1, ((world.halfWidth * 2 - 3) / 2.4).floor());
    for (var i = 0; i < sides.length; i++) {
      final row = i ~/ perRow;
      final inRow = min(perRow, sides.length - row * perRow);
      final slot = (i % perRow - (inRow - 1) / 2) * 2.4;
      final turn = rng.range(-0.18, 0.18);
      final dir = Vec3(
        heading.x * cos(turn) - heading.z * sin(turn),
        0,
        heading.x * sin(turn) + heading.z * cos(turn),
      );
      final speed = (5.5 + 6.5 * p) * rng.range(0.85, 1.15);
      world.add(
        DieBody(
          shape: ConvexShape.forSides(sides[i]),
          pos: Vec3(
            slot + rng.range(-0.3, 0.3),
            2.2 + rng.range(0, 1.2) + row * 1.8,
            world.halfDepth - 1.4 - row * 2.2 + rng.range(-0.3, 0.3),
          ),
          rot: Quat.random(rng),
          vel: Vec3(dir.x * speed, rng.range(3, 6) * p, dir.z * speed),
          omega: _spin(rng, 8 + 14 * p),
        ),
      );
    }
  }

  Vec3 _spin(SeededRandom rng, double rate) {
    final axis = Vec3(
      rng.range(-1, 1),
      rng.range(-1, 1),
      rng.range(-1, 1),
    ).unit;
    return axis * (rate * rng.range(0.7, 1.2));
  }
}
