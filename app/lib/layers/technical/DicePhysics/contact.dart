import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';

enum DieImpactKind { table, wall, die }

class Contact {
  Contact({
    required this.a,
    required this.b,
    required this.point,
    required this.normal,
    required this.depth,
    required this.kind,
    this.friction = 0.55,
    this.restitution = 0.38,
  }) {
    approach = -_relative().dot(normal);
    bounce = approach > 2.5 ? approach * restitution : 0;
  }

  final DieBody a;
  final DieBody? b;
  final Vec3 point, normal;
  final double depth, friction, restitution;
  final DieImpactKind kind;
  late final double approach, bounce;
  double normalImpulse = 0;
  Vec3 tangentImpulse = Vec3.zero;

  Vec3 _velocityAt(DieBody body) =>
      body.vel + body.omega.cross(point - body.pos);

  Vec3 _relative() {
    final other = b;
    return other == null ? _velocityAt(a) : _velocityAt(a) - _velocityAt(other);
  }

  double _mass(Vec3 axis) {
    final ra = point - a.pos;
    var k = a.invMass + a.invInertia * ra.cross(axis).dot(ra.cross(axis));
    final other = b;
    if (other != null) {
      final rb = point - other.pos;
      k +=
          other.invMass + other.invInertia * rb.cross(axis).dot(rb.cross(axis));
    }
    return k;
  }

  void _apply(Vec3 impulse) {
    a.vel = a.vel + impulse * a.invMass;
    a.omega = a.omega + (point - a.pos).cross(impulse) * a.invInertia;
    final other = b;
    if (other == null) return;
    other.vel = other.vel - impulse * other.invMass;
    other.omega =
        other.omega - (point - other.pos).cross(impulse) * other.invInertia;
  }

  void solve() {
    final vn = _relative().dot(normal);
    final wanted = max(0.0, normalImpulse - (vn - bounce) / _mass(normal));
    final delta = wanted - normalImpulse;
    normalImpulse = wanted;
    _apply(normal * delta);
    final slide = _relative() - normal * _relative().dot(normal);
    if (slide.length < 1e-9) return;
    final dir = slide.unit;
    var total = tangentImpulse - slide * (1 / _mass(dir));
    final limit = friction * normalImpulse;
    if (total.length > limit) total = total.unit * limit;
    _apply(total - tangentImpulse);
    tangentImpulse = total;
  }

  void correct(double slop, double factor) {
    final push = max(0.0, depth - slop) * factor;
    if (push == 0) return;
    final other = b;
    final share = a.invMass + (other?.invMass ?? 0);
    a.pos = a.pos + normal * (push * a.invMass / share);
    if (other != null) {
      other.pos = other.pos - normal * (push * other.invMass / share);
    }
  }
}
