import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Physics/tray_physics.dart';

TrayPhysics rig(
  int count, {
  SurfaceMaterial surface = SurfaceMaterial.wood,
}) => TrayPhysics(
  width: 320,
  height: 300,
  radius: 28,
  count: count,
  surface: surface,
);

List<int> roll(int seed, List<int> sides) {
  final p = rig(sides.length);
  p
    ..launch(SeededRandom(seed), const {}, sides: sides)
    ..settle(const {});
  return p.outcome();
}

double energy(TrayBody b) =>
    0.5 * (b.vx * b.vx + b.vy * b.vy + b.vz * b.vz) + 2400 * b.z;

TrayBody free({double z = 0}) => TrayBody(x: 160, y: 150)
  ..z = z
  ..asleep = false;

int stepsToRest(int seed, int sides) {
  final p = rig(1)..launch(SeededRandom(seed), const {}, sides: [sides]);
  var n = 0;
  while (p.isMoving(const {}) && n < 2000) {
    p.advance(TrayPhysics.step, const {});
    n++;
  }
  return n;
}

void main() {
  for (final n in [2, 6, 20, 100]) {
    test('a $n-sided die settles on a face between 1 and $n, seeded', () {
      expect(roll(4, [n]), roll(4, [n]));
      for (var seed = 1; seed < 60; seed++) {
        expect(roll(seed, [n]).single, inInclusiveRange(1, n));
      }
    });
  }

  test('outcomes are spread uniformly over the faces', () {
    final coin = [for (var s = 1; s <= 300; s++) roll(s, [2]).single];
    final heads = coin.where((v) => v == 1).length;
    expect(heads, inInclusiveRange(105, 195));
    final six = {for (var s = 1; s <= 300; s++) roll(s, [6]).single};
    expect(six, {1, 2, 3, 4, 5, 6});
    final hundred = {for (var s = 1; s <= 300; s++) roll(s, [100]).single};
    expect(hundred.length, greaterThan(50));
  });

  test('the live simulation lands on the rehearsed outcome', () {
    const sides = [6, 20, 2, 100];
    final live = rig(4)..launch(SeededRandom(9), const {}, sides: sides);
    final rehearsal = live.copy()..settle(const {});
    while (live.isMoving(const {})) {
      live.advance(TrayPhysics.step, const {});
    }
    expect(live.outcome(), rehearsal.outcome());
  });

  test('kinetic and potential energy only go down', () {
    final p = rig(1)..launch(SeededRandom(3), const {});
    final samples = <double>[];
    for (var step = 0; step <= 240; step++) {
      if (step % 60 == 0 && step != 180) samples.add(energy(p.bodies.first));
      p.advance(TrayPhysics.step, const {});
    }
    expect(samples[1], lessThan(samples[0]));
    expect(samples[2], lessThanOrEqualTo(samples[1]));
    expect(samples[3], lessThanOrEqualTo(samples[2]));
  });

  test('a stronger throw hits harder', () {
    double peak(double power) {
      var best = 0.0;
      final p = rig(1);
      p.onImpact = (hit) => best = best < hit.speed ? hit.speed : best;
      p
        ..launch(SeededRandom(5), const {}, power: power)
        ..settle(const {});
      return best;
    }

    expect(peak(1.4), greaterThan(peak(0.3)));
  });

  test('dice sleep: nothing moves after rest', () {
    final p = rig(5)..launch(SeededRandom(2), const {});
    p.settle(const {});
    expect(p.isMoving(const {}), isFalse);
    for (final b in p.bodies) {
      expect([b.vx, b.vy, b.vz, b.spin, b.z], everyElement(0));
      expect(b.asleep, isTrue);
    }
  });

  test('twelve dice reach rest within the settle budget', () {
    final p = rig(12)
      ..launch(SeededRandom(8), const {}, sides: List.filled(12, 20));
    var n = 0;
    while (p.isMoving(const {}) && n < 900) {
      p.advance(TrayPhysics.step, const {});
      n++;
    }
    expect(p.isMoving(const {}), isFalse);
  });

  test('two dice collide and exchange momentum', () {
    final p = TrayPhysics(width: 400, height: 300, radius: 28, count: 2);
    final hits = <ImpactKind>[];
    p.onImpact = (hit) => hits.add(hit.kind);
    p.bodies[0]
      ..x = 100
      ..y = 150
      ..vx = 300
      ..asleep = false;
    p.bodies[1]
      ..x = 150
      ..y = 150
      ..asleep = false;
    p.advance(TrayPhysics.step, const {});
    expect(hits, contains(ImpactKind.die));
    expect(p.bodies[1].vx, greaterThan(100));
    expect(p.bodies[0].vx, lessThan(100));
  });

  test('a wall bounces the die back with lost speed', () {
    final p = rig(1);
    p.bodies[0]
      ..x = 29
      ..y = 150
      ..vx = -400
      ..asleep = false;
    p.advance(TrayPhysics.step, const {});
    expect(p.bodies[0].vx, inExclusiveRange(0, 300));
  });

  test('glass bounces more than wood, wood more than felt', () {
    double rebound(SurfaceMaterial surface) {
      final p = rig(1, surface: surface);
      p.bodies[0] = free(z: 100);
      var hit = false;
      p.onImpact = (_) => hit = true;
      for (var i = 0; i < 120 && !hit; i++) {
        p.advance(TrayPhysics.step, const {});
      }
      return p.bodies[0].vz;
    }

    final glass = rebound(SurfaceMaterial.glass);
    final wood = rebound(SurfaceMaterial.wood);
    final felt = rebound(SurfaceMaterial.felt);
    expect(glass, greaterThan(wood));
    expect(wood, greaterThan(felt));
  });

  test('a tilt makes a resting die slide without changing its face', () {
    final p = rig(1)
      ..launch(SeededRandom(6), const {}, sides: [20])
      ..settle(const {});
    p.bodies.first
      ..x = 200
      ..y = 150;
    final face = p.bodies.first.face;
    final x = p.bodies.first.x;
    expect(p.setTilt(0.05, 0, const {}), isFalse);
    expect(p.setTilt(-0.9, 0, const {}), isTrue);
    for (var i = 0; i < 40; i++) {
      p.advance(TrayPhysics.step, const {});
    }
    expect(p.bodies.first.x, lessThan(x));
    expect(p.bodies.first.face, face);
  });

  test('a hundred-sided die rolls longer than a cube', () {
    var cube = 0, ball = 0;
    for (var seed = 1; seed <= 8; seed++) {
      cube += stepsToRest(seed, 6);
      ball += stepsToRest(seed, 100);
    }
    expect(ball, greaterThan(cube));
    expect(TrayBody.roundnessFor(100), 1);
    expect(TrayBody.roundnessFor(6), 0);
  });
}
