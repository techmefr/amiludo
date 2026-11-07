import 'dart:ui';

import 'package:flutter/foundation.dart';

const double _minSpeed = 400;

class TrayFlick {
  const TrayFlick(this.power, this.aim);

  final double power;
  final Offset aim;
}

TrayFlick? flickOf(Offset velocity) {
  if (velocity.distance < _minSpeed) return null;
  return TrayFlick(
    (velocity.distance / 1800).clamp(0.5, 1.5),
    velocity / velocity.distance,
  );
}

void routeSwipe(
  Offset v,
  void Function(double power, Offset aim)? onFlick, {
  VoidCallback? lock,
}) {
  if (lock != null) {
    if (isLockSwipe(v)) return lock();
    if (v.dy >= 0) return;
  }
  final f = flickOf(v);
  if (f != null) onFlick?.call(f.power, f.aim);
}

bool isLockSwipe(Offset v) =>
    v.distance >= _minSpeed && v.dx < 0 && v.dx.abs() > v.dy.abs();
