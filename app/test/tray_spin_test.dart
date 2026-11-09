import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/die_orient.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pose.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/tray_physics.dart';

TrayPhysics rig(int count) =>
    TrayPhysics(width: 320, height: 300, radius: 28, count: count);

double gap(Mat3 a, Mat3 b) {
  final q = b * transposed(a);
  return (q.r0.x + q.r1.y + q.r2.z - 3).abs();
}

void main() {
  test('a turn about an axis is a rotation', () {
    final m = turnAbout(const Vec3(1, 2, 3), 1.1);
    expect(m.r0.length, closeTo(1, 1e-9));
    expect(m.r0.dot(m.r1), closeTo(0, 1e-9));
    expect(m.r0.cross(m.r1).dot(m.r2), closeTo(1, 1e-9));
  });

  test('settling turns an orientation onto its target and nowhere else', () {
    final from = turnAbout(const Vec3(0, 1, 1), 2.4);
    final target = turnAbout(const Vec3(1, 0, 0), 0.7);
    expect(gap(settleToward(from, target, 0), from), closeTo(0, 1e-9));
    expect(gap(settleToward(from, target, 1), target), closeTo(0, 1e-9));
    final half = settleToward(from, target, 0.5);
    expect(half.r0.length, closeTo(1, 1e-9));
    expect(gap(half, from), greaterThan(0));
    expect(gap(half, target), greaterThan(0));
  });

  test('a half turn settles through a valid rotation', () {
    final half = settleToward(Mat3.identity, turnAbout(const Vec3(0, 0, 1), 3.14159265358979), 0.5);
    expect(half.r0.cross(half.r1).dot(half.r2), closeTo(1, 1e-6));
  });

  test('a thrown die tumbles freely in 3D, then lands on its face', () {
    final p = rig(3)..launch(SeededRandom(7), const {});
    final start = [for (final b in p.bodies) b.rot];
    for (var i = 0; i < 20; i++) {
      p.advance(TrayPhysics.step, const {});
    }
    for (var i = 0; i < 3; i++) {
      expect(gap(p.bodies[i].rot, start[i]), greaterThan(1e-3));
      expect(p.bodies[i].settled, lessThan(1));
      expect(p.bodies[i].rot.r0.length, closeTo(1, 1e-6));
    }
    p.settle(const {});
    for (final b in p.bodies) {
      expect(b.settled, 1);
    }
  });

  test('the free tumble is deterministic for a seed', () {
    List<double> spin(int seed) {
      final p = rig(2)..launch(SeededRandom(seed), const {});
      for (var i = 0; i < 90; i++) {
        p.advance(TrayPhysics.step, const {});
      }
      return [for (final b in p.bodies) ...[b.rot.r0.x, b.rot.r1.y]];
    }

    expect(spin(5), spin(5));
    expect(spin(5), isNot(spin(6)));
  });

  test('a landed die shows its chosen face to the viewer', () {
    final mesh = DieMesh.forSides(20);
    final shown = DiePose.spinning(mesh, 4, 0, 0, turnAbout(const Vec3(1, 1, 0), 2), 1);
    final rest = DiePose.resting(mesh, 4);
    expect(gap(shown, rest), closeTo(0, 1e-9));
  });
}
