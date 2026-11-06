import 'dart:math';

import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

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
}

class TrayPhysics {
  TrayPhysics({
    required this.width,
    required this.height,
    required this.radius,
    required int count,
  }) : bodies = List.generate(count, (_) => TrayBody()) {
    _scatter();
  }

  static const double step = 1 / 60;
  static const double _wallBounce = 0.62;
  static const double _hitBounce = 0.8;
  static const double _drag = 2.4;
  static const double _rest = 6;
  static const int _maxSettleSteps = 900;

  final double width, height, radius;
  final List<TrayBody> bodies;

  void _scatter() {
    final columns = max(1, ((width - radius) / (radius * 2.4)).floor());
    for (var i = 0; i < bodies.length; i++) {
      bodies[i]
        ..x = radius + (i % columns) * radius * 2.4 + radius * 0.2
        ..y = radius + (i ~/ columns) * radius * 2.4 + radius * 0.2;
      _clamp(bodies[i]);
    }
  }

  void launch(SeededRandom rng, Set<int> kept) {
    for (var i = 0; i < bodies.length; i++) {
      if (kept.contains(i)) continue;
      final heading = rng.range(0, 2 * pi);
      final force = rng.range(width, width * 2.2);
      bodies[i]
        ..x = rng.range(radius, max(radius, width - radius))
        ..y = rng.range(radius, max(radius, height - radius))
        ..vx = cos(heading) * force
        ..vy = sin(heading) * force
        ..angle = rng.range(0, 2 * pi)
        ..spin = rng.range(-14, 14);
    }
  }

  bool isMoving(Set<int> kept) {
    for (var i = 0; i < bodies.length; i++) {
      if (kept.contains(i)) continue;
      final b = bodies[i];
      if (b.vx.abs() + b.vy.abs() > _rest || b.spin.abs() > 0.4) return true;
    }
    return false;
  }

  void advance(double dt, Set<int> kept) {
    final damping = max(0.0, 1 - _drag * dt);
    for (var i = 0; i < bodies.length; i++) {
      if (kept.contains(i)) continue;
      final b = bodies[i];
      b
        ..x += b.vx * dt
        ..y += b.vy * dt
        ..angle += b.spin * dt
        ..vx *= damping
        ..vy *= damping
        ..spin *= damping;
      _bounce(b);
      if (b.vx.abs() + b.vy.abs() <= _rest) {
        b
          ..vx = 0
          ..vy = 0;
      }
    }
    _collide(kept);
  }

  void settle(Set<int> kept) {
    for (var n = 0; n < _maxSettleSteps && isMoving(kept); n++) {
      advance(step, kept);
    }
    for (final b in bodies) {
      b
        ..vx = 0
        ..vy = 0
        ..spin = 0;
    }
  }

  void _clamp(TrayBody b) {
    b
      ..x = b.x.clamp(radius, max(radius, width - radius))
      ..y = b.y.clamp(radius, max(radius, height - radius));
  }

  void _bounce(TrayBody b) {
    if (b.x < radius || b.x > width - radius) b.vx = -b.vx * _wallBounce;
    if (b.y < radius || b.y > height - radius) b.vy = -b.vy * _wallBounce;
    _clamp(b);
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
    }
    _clamp(a);
    _clamp(b);
  }
}
