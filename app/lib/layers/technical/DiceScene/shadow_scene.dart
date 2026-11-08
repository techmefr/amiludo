import 'dart:math';
import 'dart:ui';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_light.dart';

List<Offset> convexHull(List<Offset> points) {
  if (points.length < 3) return points;
  final sorted = [
    ...points,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final p in sorted) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in sorted.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  return [...lower..removeLast(), ...upper..removeLast()];
}

List<Vec3> _footprint(DieBody body) {
  if (!body.shape.sphere) return body.worldVertices;
  return [
    for (var i = 0; i < 14; i++)
      body.pos + Vec3(cos(i * pi / 7), 0, sin(i * pi / 7)) * body.size,
    body.pos + Vec3(0, body.size, 0),
    body.pos - Vec3(0, body.size, 0),
  ];
}

Vec3 _along(Vec3 p) {
  final y = max(0.0, p.y);
  return Vec3(
    p.x - lightDirection.x / lightDirection.y * y,
    0,
    p.z - lightDirection.z / lightDirection.y * y,
  );
}

void _blob(
  Canvas canvas,
  SceneCamera cam,
  List<Vec3> ground,
  double alpha,
  double sigma,
) {
  final hull = convexHull([for (final g in ground) cam.project(g)]);
  if (hull.length < 3) return;
  canvas.drawPath(
    Path()..addPolygon(hull, true),
    Paint()
      ..color = Color.fromRGBO(0, 0, 0, alpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, max(1.5, sigma)),
  );
}

void paintShadows(Canvas canvas, SceneCamera cam, List<DieBody> bodies) {
  for (final body in bodies) {
    final points = _footprint(body);
    var low = double.infinity;
    for (final p in points) {
      low = min(low, p.y);
    }
    final lift = max(0.0, low);
    final fade = 1 / (1 + lift * 0.35);
    final scale = cam.scaleAt(body.pos);
    _blob(
      canvas,
      cam,
      [for (final p in points) _along(p)],
      0.38 * fade,
      scale * (0.22 + lift * 0.16),
    );
    _blob(
      canvas,
      cam,
      [for (final p in points) Vec3(p.x, 0, p.z)],
      0.3 * fade,
      scale * 0.14,
    );
  }
}
