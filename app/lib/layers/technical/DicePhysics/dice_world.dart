import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/collision_detector.dart';
import 'package:amiludo/layers/technical/DicePhysics/contact.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';

class DiceWorld {
  DiceWorld({
    required this.halfWidth,
    required this.halfDepth,
    this.gravity = 60,
  }) : walls = [
         const Wall(Vec3(0, 1, 0), 0, DieImpactKind.table),
         Wall(const Vec3(1, 0, 0), -halfWidth, DieImpactKind.wall),
         Wall(const Vec3(-1, 0, 0), -halfWidth, DieImpactKind.wall),
         Wall(const Vec3(0, 0, 1), -halfDepth, DieImpactKind.wall),
         Wall(const Vec3(0, 0, -1), -halfDepth, DieImpactKind.wall),
       ];

  static const double step = 1 / 120;
  static const int _iterations = 10;
  static const double _quiet = 0.3;

  final double halfWidth, halfDepth, gravity;
  final List<Wall> walls;
  final List<DieBody> bodies = [];
  void Function(DieImpactKind kind, double speed)? onImpact;

  bool get settled => bodies.every((b) => b.asleep);

  void add(DieBody body) => bodies.add(body);

  void advance() {
    final awake = [
      for (final b in bodies)
        if (!b.asleep) b,
    ];
    for (final b in awake) {
      b.vel =
          Vec3(b.vel.x, b.vel.y - gravity * step, b.vel.z) * (1 - 0.02 * step);
      b.omega = b.omega * (1 - 0.1 * step);
      b.grounded = false;
    }
    final contacts = _detect();
    for (final c in contacts) {
      if (c.kind == DieImpactKind.table) c.a.grounded = true;
      if (c.approach > 4) onImpact?.call(c.kind, c.approach);
    }
    for (var i = 0; i < _iterations; i++) {
      for (final c in contacts) {
        c.solve();
      }
    }
    for (final c in contacts) {
      c.correct(0.01, 0.2);
    }
    for (final b in awake) {
      _integrate(b);
    }
  }

  List<Contact> _detect() {
    final found = <Contact>[];
    for (var i = 0; i < bodies.length; i++) {
      final a = bodies[i];
      if (!a.asleep) found.addAll(wallContacts(a, walls));
      for (var j = i + 1; j < bodies.length; j++) {
        final b = bodies[j];
        if (a.asleep && b.asleep) continue;
        final pairs = pairContacts(a, b);
        if (pairs.isEmpty) continue;
        if (a.asleep && b.energy > _quiet) a.wake();
        if (b.asleep && a.energy > _quiet) b.wake();
        found.addAll(pairs);
      }
    }
    return [
      for (final c in found)
        if (!c.a.asleep || !(c.b?.asleep ?? true)) c,
    ];
  }

  void _integrate(DieBody b) {
    if (b.shape.sphere && b.grounded) {
      b.omega = b.omega * (1 - 2.5 * step);
      b.vel = b.vel * (1 - 1.2 * step);
    }
    b.pos = b.pos + b.vel * step;
    b.rot = b.rot.integrated(b.omega, step);
    if (!b.grounded) {
      b.still = 0;
      return;
    }
    if (b.vel.length > 0.6 || b.omega.length > 1.5) {
      b.still = 0;
      return;
    }
    if (b.shape.hasStableFaces && b.alignment() < 0.998) {
      b.omega = b.omega + b.tipAxis() * (14 * step);
      b.still = 0;
      if (++b.leaning % 180 == 0) {
        b.vel = Vec3(-b.pos.x * 0.5, 4, -b.pos.z * 0.5);
      }
      return;
    }
    if (b.vel.length < 0.25 && b.omega.length < 0.35 && ++b.still > 30) {
      b.sleep();
    }
  }

  void freeze() {
    for (final b in bodies) {
      b.sleep();
    }
  }
}
