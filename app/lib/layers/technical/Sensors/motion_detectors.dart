import 'dart:math' as math;

import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';

const _gravity = 9.80665;

class ShakeDetector {
  ShakeDetector({
    required this.threshold,
    this.window = const Duration(milliseconds: 700),
    this.cooldown = const Duration(milliseconds: 1000),
  });

  final double threshold;
  final Duration window;
  final Duration cooldown;
  DateTime? _firstSpike;
  DateTime? _lastShake;
  AccelSample? _previous;

  bool add(AccelSample sample, DateTime now) {
    final previous = _previous;
    _previous = sample;
    final last = _lastShake;
    if (last != null && now.difference(last) < cooldown) return false;
    final magnitude = math.sqrt(
      sample.x * sample.x + sample.y * sample.y + sample.z * sample.z,
    );
    if ((magnitude - _gravity).abs() < threshold) {
      if (previous == null) return false;
      final dx = sample.x - previous.x;
      final dy = sample.y - previous.y;
      final dz = sample.z - previous.z;
      if (dx * dx + dy * dy + dz * dz < threshold * threshold) return false;
    }
    final first = _firstSpike;
    if (first == null || now.difference(first) > window) {
      _firstSpike = now;
      return false;
    }
    _firstSpike = null;
    _lastShake = now;
    return true;
  }
}

class TurnDetector {
  TurnDetector({
    this.edge = 6,
    this.cooldown = const Duration(milliseconds: 800),
  });

  final double edge;
  final Duration cooldown;
  int _ySide = 0;
  int _zSide = 0;
  DateTime? _lastTurn;

  bool add(AccelSample sample, DateTime now) {
    final y = _cross(sample.y, _ySide);
    final z = _cross(sample.z, _zSide);
    _ySide = y.side;
    _zSide = z.side;
    if (!y.flipped && !z.flipped) return false;
    final last = _lastTurn;
    if (last != null && now.difference(last) < cooldown) return false;
    _lastTurn = now;
    return true;
  }

  ({int side, bool flipped}) _cross(double value, int side) {
    if (value > edge) return (side: 1, flipped: side == -1);
    if (value < -edge) return (side: -1, flipped: side == 1);
    return (side: side, flipped: false);
  }
}
