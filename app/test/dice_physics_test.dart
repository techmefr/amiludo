import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/dice_simulation.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';

const _all = [2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 30, 60, 100, 1000];

DiceSimulation _run(List<int> sides, int seed, {double power = 1}) {
  final run = DiceSimulation(sides: sides, seed: seed, power: power);
  run.settle();
  return run;
}

void main() {
  test('every die settles, rests inside the table and reads a valid face', () {
    for (final sides in _all) {
      for (var seed = 1; seed <= 6; seed++) {
        final run = _run([sides], seed);
        expect(run.settled, isTrue, reason: 'd$sides seed $seed');
        final body = run.bodies.single;
        expect(body.pos.x.abs(), lessThan(run.world.halfWidth));
        expect(body.pos.z.abs(), lessThan(run.world.halfDepth));
        expect(body.pos.y, lessThan(1.2), reason: 'd$sides seed $seed');
        final value = run.values.single;
        expect(value, inInclusiveRange(1, sides), reason: 'd$sides');
      }
    }
  });

  test('flat dice rest on a face, not on an edge', () {
    for (final sides in [4, 6, 8, 10, 12, 20]) {
      for (var seed = 1; seed <= 8; seed++) {
        final body = _run([sides], seed).bodies.single;
        expect(body.alignment(), greaterThan(0.98), reason: 'd$sides $seed');
      }
    }
  });

  test('the same seed always gives the same outcome and positions', () {
    final a = _run([6, 20, 8, 12], 4242);
    final b = _run([6, 20, 8, 12], 4242);
    expect(a.values, b.values);
    for (var i = 0; i < 4; i++) {
      expect(a.bodies[i].pos.x, b.bodies[i].pos.x);
      expect(a.bodies[i].pos.z, b.bodies[i].pos.z);
    }
    expect(
      DiceSimulation.roll([6, 6, 6], 9),
      DiceSimulation.roll([6, 6, 6], 9),
    );
  });

  test('different seeds give different outcomes', () {
    final seen = {
      for (var s = 1; s <= 30; s++) _run([20], s).values.single,
    };
    expect(seen.length, greaterThan(8));
  });

  test('a d6 and a d20 are plausibly fair over many throws', () {
    for (final sides in [6, 20]) {
      const throws = 400;
      final counts = List.filled(sides + 1, 0);
      for (var s = 1; s <= throws; s++) {
        counts[_run([sides], s * 7919).values.single]++;
      }
      final expected = throws / sides;
      for (var face = 1; face <= sides; face++) {
        expect(
          counts[face],
          greaterThan(expected * 0.3),
          reason: 'd$sides $face',
        );
        expect(counts[face], lessThan(expected * 2.4), reason: 'd$sides $face');
      }
    }
  });

  test('dice collide and never end up overlapping', () {
    final run = _run(List.filled(8, 6), 77);
    final bodies = run.bodies;
    for (var i = 0; i < bodies.length; i++) {
      for (var j = i + 1; j < bodies.length; j++) {
        final gap = (bodies[i].pos - bodies[j].pos).length;
        expect(gap, greaterThan(0.9), reason: 'dice $i and $j');
      }
    }
  });

  test('a harder throw hits the table harder', () {
    double hardest(double power) {
      var top = 0.0;
      for (var s = 1; s <= 10; s++) {
        final run = DiceSimulation(sides: const [6], seed: s, power: power);
        run.world.onImpact = (kind, speed) => top = speed > top ? speed : top;
        run.settle();
      }
      return top;
    }

    expect(hardest(1.4), greaterThan(hardest(0.3)));
  });

  test('impacts are reported with a speed', () {
    final run = DiceSimulation(sides: const [6, 6], seed: 5);
    var hits = 0;
    run.world.onImpact = (kind, speed) => hits += speed > 0 ? 1 : 0;
    run.settle();
    expect(hits, greaterThan(0));
  });

  group('shake strength', () {
    test('a stronger jolt gives a stronger throw', () {
      final soft = strengthOf(const AccelSample(0, 0, 22), 11);
      final hard = strengthOf(const AccelSample(0, 0, 45), 11);
      expect(hard, greaterThan(soft));
      expect(strengthOf(const AccelSample(0, 0, 200), 11), 1.5);
      expect(strengthOf(const AccelSample(0, 0, 9.8), 11), 0.25);
    });

    test('a vertical flick is detected, a flat hold is not', () {
      expect(isFlick(const AccelSample(0, 30, 0), 11), isTrue);
      expect(isFlick(const AccelSample(0, 0, 9.8), 11), isFalse);
      expect(isFlick(const AccelSample(25, 25, 0), 11), isFalse);
    });

    test('the throw power maps onto the launch speed', () {
      final low = DiceSimulation(sides: const [6], seed: 1, power: 0.25);
      final high = DiceSimulation(sides: const [6], seed: 1, power: 1.5);
      expect(
        high.bodies.single.vel.length,
        greaterThan(low.bodies.single.vel.length),
      );
      expect(
        high.bodies.single.omega.length,
        greaterThan(low.bodies.single.omega.length),
      );
      expect(Vec3.zero.length, 0);
    });
  });
}
