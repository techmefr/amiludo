import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

Mat3 turnAbout(Vec3 axis, double angle) {
  final u = axis.unit;
  final c = cos(angle), s = sin(angle), t = 1 - c;
  return Mat3(
    Vec3(t * u.x * u.x + c, t * u.x * u.y - s * u.z, t * u.x * u.z + s * u.y),
    Vec3(t * u.x * u.y + s * u.z, t * u.y * u.y + c, t * u.y * u.z - s * u.x),
    Vec3(t * u.x * u.z - s * u.y, t * u.y * u.z + s * u.x, t * u.z * u.z + c),
  );
}

Mat3 transposed(Mat3 m) => Mat3(
  Vec3(m.r0.x, m.r1.x, m.r2.x),
  Vec3(m.r0.y, m.r1.y, m.r2.y),
  Vec3(m.r0.z, m.r1.z, m.r2.z),
);

Vec3 _axisOf(Mat3 q) {
  final skew = Vec3(q.r2.y - q.r1.z, q.r0.z - q.r2.x, q.r1.x - q.r0.y);
  if (skew.length > 1e-9) return skew.unit;
  final columns = [
    Vec3(q.r0.x + 1, q.r1.x, q.r2.x),
    Vec3(q.r0.y, q.r1.y + 1, q.r2.y),
    Vec3(q.r0.z, q.r1.z, q.r2.z + 1),
  ]..sort((a, b) => b.length.compareTo(a.length));
  return columns.first.unit;
}

Mat3 settleToward(Mat3 from, Mat3 target, double t) {
  if (t <= 0) return from;
  if (t >= 1) return target;
  final q = target * transposed(from);
  final trace = q.r0.x + q.r1.y + q.r2.z;
  final angle = acos(((trace - 1) / 2).clamp(-1.0, 1.0));
  if (angle < 1e-9) return target;
  return turnAbout(_axisOf(q), angle * t) * from;
}
