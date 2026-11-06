import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/tray_physics.dart';

TrayPhysics settled(int seed, {Set<int> kept = const {}}) {
  final physics = TrayPhysics(width: 320, height: 300, radius: 28, count: 5);
  physics
    ..launch(SeededRandom(seed), kept)
    ..settle(kept);
  return physics;
}

List<List<double>> snapshot(TrayPhysics p) => [
  for (final b in p.bodies) [b.x, b.y, b.angle],
];

void main() {
  test('the same seed gives the same random sequence', () {
    final a = SeededRandom(42), b = SeededRandom(42), c = SeededRandom(43);
    final first = List.generate(8, (_) => a.nextInt(1000));
    expect(List.generate(8, (_) => b.nextInt(1000)), first);
    expect(List.generate(8, (_) => c.nextInt(1000)), isNot(first));
  });

  test('a seeded throw always settles on the same positions', () {
    expect(snapshot(settled(7)), snapshot(settled(7)));
    expect(snapshot(settled(7)), isNot(snapshot(settled(8))));
  });

  test('dice stay inside the tray and do not overlap once settled', () {
    final p = settled(11);
    for (final b in p.bodies) {
      expect(b.x, inInclusiveRange(28, 320 - 28));
      expect(b.y, inInclusiveRange(28, 300 - 28));
    }
    for (var i = 0; i < p.bodies.length; i++) {
      for (var j = i + 1; j < p.bodies.length; j++) {
        final dx = p.bodies[i].x - p.bodies[j].x;
        final dy = p.bodies[i].y - p.bodies[j].y;
        expect(dx * dx + dy * dy, greaterThan(50 * 50));
      }
    }
  });

  test('a kept die is never moved by a throw', () {
    final p = TrayPhysics(width: 320, height: 300, radius: 28, count: 3);
    final before = [p.bodies[1].x, p.bodies[1].y];
    p
      ..launch(SeededRandom(3), {1})
      ..settle({1});
    expect([p.bodies[1].x, p.bodies[1].y], before);
  });

  test('stepping with a fixed timestep reaches rest', () {
    final p = TrayPhysics(width: 320, height: 300, radius: 28, count: 4)
      ..launch(SeededRandom(5), const {});
    var steps = 0;
    while (p.isMoving(const {}) && steps < 2000) {
      p.advance(TrayPhysics.step, const {});
      steps++;
    }
    expect(p.isMoving(const {}), isFalse);
    expect(steps, lessThan(2000));
  });
}
