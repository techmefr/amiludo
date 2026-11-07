import 'dart:math';

import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Physics/tray_body.dart';

export 'package:amiludo/layers/technical/Physics/tray_body.dart';

class TrayPhysics {
  TrayPhysics({
    required this.width,
    required this.height,
    required this.radius,
    required int count,
    this.surface = SurfaceMaterial.wood,
  }) : bodies = List.generate(count, (_) => TrayBody()) {
    _scatter();
  }

  TrayPhysics._copy(TrayPhysics o)
    : width = o.width,
      height = o.height,
      radius = o.radius,
      surface = o.surface,
      bodies = [for (final b in o.bodies) b.copy()],
      _rolled = o._rolled;

  static const double step = 1 / 60;
  static const double _gravity = 2400;
  static const double _hitBounce = 0.8;
  static const double _rest = 6;
  static const double _hitMin = 30;
  static const double _tiltAccel = 900;
  static const int _maxRollSteps = 600;
  static const int _maxSettleSteps = 900;

  final double width, height, radius;
  final SurfaceMaterial surface;
  final List<TrayBody> bodies;
  double tiltX = 0, tiltY = 0;
  void Function(TrayImpact impact)? onImpact;
  int _rolled = 0;

  TrayPhysics copy() => TrayPhysics._copy(this);

  List<int> outcome() => [for (final b in bodies) b.face];

  void _scatter() {
    final columns = max(1, ((width - radius) / (radius * 2.4)).floor());
    for (var i = 0; i < bodies.length; i++) {
      bodies[i]
        ..x = radius + (i % columns) * radius * 2.4 + radius * 0.2
        ..y = radius + (i ~/ columns) * radius * 2.4 + radius * 0.2;
      _clamp(bodies[i]);
    }
  }

  void launch(
    SeededRandom rng,
    Set<int> kept, {
    double power = 1,
    List<int> sides = const [],
    double aimX = 0,
    double aimY = 0,
  }) {
    final p = power.clamp(0.2, 1.5);
    _rolled = 0;
    for (var i = 0; i < bodies.length; i++) {
      if (kept.contains(i)) continue;
      launchBody(
        bodies[i],
        rng,
        width: width,
        height: height,
        radius: radius,
        index: i,
        count: bodies.length,
        sides: i < sides.length ? sides[i] : 6,
        power: p,
        aimX: aimX,
        aimY: aimY,
      );
    }
  }

  bool isMoving(Set<int> kept) {
    for (var i = 0; i < bodies.length; i++) {
      if (!kept.contains(i) && !bodies[i].asleep) return true;
    }
    return false;
  }

  bool setTilt(double x, double y, Set<int> kept) {
    tiltX = x;
    tiltY = y;
    return isMoving(kept) || bodies.any((b) => _wakes(b));
  }

  bool _wakes(TrayBody b) {
    final lean = sqrt(tiltX * tiltX + tiltY * tiltY);
    return b.asleep && lean > 0.15 + surface.friction * 0.05;
  }

  double _grip(TrayBody b) => surface.friction * (1 - 0.6 * b.roundness);

  void advance(double dt, Set<int> kept) {
    for (var i = 0; i < bodies.length; i++) {
      if (kept.contains(i)) continue;
      final b = bodies[i];
      if (b.asleep) {
        if (!_wakes(b)) continue;
        b.asleep = false;
      }
      _move(b, dt);
    }
    _collide(kept);
    if (++_rolled > _maxRollSteps) {
      for (final b in bodies) {
        if (b.rolling && !kept.contains(bodies.indexOf(b))) b.sleep();
      }
    }
  }

  void _move(TrayBody b, double dt) {
    final air = b.z > 0 || b.vz != 0;
    if (air) _fall(b, dt);
    if (!b.rolling) {
      b
        ..vx += tiltX * _tiltAccel * dt
        ..vy += tiltY * _tiltAccel * dt;
    }
    final grip = b.z > 0 ? 0.15 : _grip(b);
    final damping = max(0.0, 1 - grip * dt);
    b
      ..vx *= damping
      ..vy *= damping
      ..spin *= damping
      ..x += b.vx * dt
      ..y += b.vy * dt
      ..angle += b.spin * dt;
    if (b.rolling) {
      final slow = b.z > 0 ? 0.35 : grip * 0.9;
      b
        ..tumble *= max(0.0, 1 - slow * dt)
        ..phase += b.tumble * dt;
    }
    _walls(b);
    final still = b.z == 0 && b.vz == 0 && b.speed <= _rest;
    final lean = sqrt(tiltX * tiltX + tiltY * tiltY);
    final held = !b.rolling && lean > 0.15 + surface.friction * 0.05;
    if (still && b.spin.abs() < 0.4 && b.tumble < 1.5 && !held) b.sleep();
  }

  void _fall(TrayBody b, double dt) {
    b
      ..vz -= _gravity * dt
      ..z += b.vz * dt;
    if (b.z > 0) return;
    final hit = -b.vz;
    final bounce = surface.floorBounce * (1 + 0.25 * b.roundness);
    b
      ..z = 0
      ..vz = hit > 60 ? hit * bounce : 0
      ..tumble *= 0.8
      ..vx *= 0.92
      ..vy *= 0.92;
    if (hit > _hitMin) onImpact?.call(TrayImpact(ImpactKind.floor, hit));
  }

  void _walls(TrayBody b) {
    final bounce = surface.wallBounce * (1 + 0.2 * b.roundness);
    final maxX = width - radius, maxY = height - radius;
    if ((b.x < radius && b.vx < 0) || (b.x > maxX && b.vx > 0)) {
      _wallHit(b.vx.abs());
      b
        ..vx = -b.vx * bounce
        ..spin *= 0.8;
    }
    if ((b.y < radius && b.vy < 0) || (b.y > maxY && b.vy > 0)) {
      _wallHit(b.vy.abs());
      b
        ..vy = -b.vy * bounce
        ..spin *= 0.8;
    }
    _clamp(b);
  }

  void _wallHit(double speed) {
    if (speed > _hitMin) onImpact?.call(TrayImpact(ImpactKind.wall, speed));
  }

  void settle(Set<int> kept) {
    for (var n = 0; n < _maxSettleSteps && isMoving(kept); n++) {
      advance(step, kept);
    }
    for (final b in bodies) {
      b.sleep();
    }
  }

  void _clamp(TrayBody b) {
    b
      ..x = b.x.clamp(radius, max(radius, width - radius))
      ..y = b.y.clamp(radius, max(radius, height - radius));
  }

  void _collide(Set<int> kept) {
    final reach = radius * 2;
    for (var i = 0; i < bodies.length; i++) {
      if (kept.contains(i)) continue;
      for (var j = i + 1; j < bodies.length; j++) {
        if (kept.contains(j)) continue;
        _resolve(bodies[i], bodies[j], reach);
      }
    }
  }

  void _resolve(TrayBody a, TrayBody b, double reach) {
    if (a.asleep && b.asleep) return;
    if ((a.z - b.z).abs() > radius * 1.5) return;
    final dx = b.x - a.x, dy = b.y - a.y;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist >= reach) return;
    final nx = dist == 0 ? 1.0 : dx / dist;
    final ny = dist == 0 ? 0.0 : dy / dist;
    final push = (reach - dist) / 2;
    a
      ..x -= nx * push
      ..y -= ny * push;
    b
      ..x += nx * push
      ..y += ny * push;
    final closing = (a.vx - b.vx) * nx + (a.vy - b.vy) * ny;
    if (closing > 0) {
      final impulse = closing * (1 + _hitBounce) / 2;
      a
        ..vx -= nx * impulse
        ..vy -= ny * impulse;
      b
        ..vx += nx * impulse
        ..vy += ny * impulse;
      final share = (a.spin - b.spin) * 0.1;
      a.spin -= share;
      b.spin += share;
      a.asleep = false;
      b.asleep = false;
      if (closing > _hitMin) {
        onImpact?.call(TrayImpact(ImpactKind.die, closing));
      }
    }
    _clamp(a);
    _clamp(b);
  }
}
