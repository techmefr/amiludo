import 'dart:math';

import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

const double rimWidth = 0.9;
const double wallHeight = 1.1;

class SceneCamera {
  SceneCamera._(
    this.eye,
    this.right,
    this.up,
    this.forward,
    this.focal,
    this.center,
  );

  factory SceneCamera.fit(
    Size size, {
    required double halfWidth,
    required double halfDepth,
    double pitch = 0.92,
    double distance = 21,
  }) {
    const target = Vec3(0, 0, 0.5);
    final eye = target + Vec3(0, sin(pitch), cos(pitch)) * distance;
    final forward = (target - eye).unit;
    final right = forward.cross(const Vec3(0, 1, 0)).unit;
    final up = right.cross(forward);
    final raw = SceneCamera._(eye, right, up, forward, 1, Offset.zero);
    final outerX = halfWidth + rimWidth, outerZ = halfDepth + rimWidth;
    final corners = [
      for (final sx in const [-1.0, 1.0])
        for (final sz in const [-1.0, 1.0]) ...[
          Vec3(sx * outerX, wallHeight, sz * outerZ),
          Vec3(sx * outerX, 0, sz * outerZ),
        ],
    ];
    var box = Rect.zero;
    var first = true;
    for (final c in corners) {
      final p = raw.project(c);
      final at = Rect.fromLTWH(p.dx, p.dy, 0, 0);
      box = first ? at : box.expandToInclude(at);
      first = false;
    }
    const pad = 6.0;
    final scale = min(
      (size.width - 2 * pad) / box.width,
      (size.height - 2 * pad) / box.height,
    );
    final center = Offset(
      size.width / 2 - scale * box.center.dx,
      size.height / 2 - scale * box.center.dy,
    );
    return SceneCamera._(eye, right, up, forward, scale, center);
  }

  final Vec3 eye, right, up, forward;
  final double focal;
  final Offset center;

  double depth(Vec3 p) => (p - eye).dot(forward);

  Offset project(Vec3 p) {
    final v = p - eye;
    final z = max(0.05, v.dot(forward));
    return Offset(
      center.dx + focal * v.dot(right) / z,
      center.dy - focal * v.dot(up) / z,
    );
  }

  double scaleAt(Vec3 p) => focal / max(0.05, depth(p));

  Vec3 toEye(Vec3 p) => (eye - p).unit;

  Matrix4 get viewProjection {
    final r0 = right * focal + forward * center.dx;
    final r1 = up * (-focal) + forward * center.dy;
    return Matrix4(
      r0.x,
      r1.x,
      0,
      forward.x,
      r0.y,
      r1.y,
      0,
      forward.y,
      r0.z,
      r1.z,
      0,
      forward.z,
      -r0.dot(eye),
      -r1.dot(eye),
      0,
      -forward.dot(eye),
    );
  }
}
