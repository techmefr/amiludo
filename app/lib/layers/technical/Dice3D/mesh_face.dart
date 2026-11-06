import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

class MeshFace {
  MeshFace._(this.corners, this.center, this.normal, this.up, this.inradius);

  factory MeshFace.fromCorners(List<Vec3> raw, {bool edgeUp = false}) {
    final center = Vec3.mean(raw);
    var normal = (raw[1] - raw[0]).cross(raw[2] - raw[0]).unit;
    if (normal.dot(center) < 0) normal = -normal;
    final a = (raw[0] - center).unit;
    final b = normal.cross(a);
    double angle(Vec3 p) => atan2((p - center).dot(b), (p - center).dot(a));
    final corners = [...raw]..sort((p, q) => angle(p).compareTo(angle(q)));
    final toward = edgeUp ? Vec3.mean([corners[0], corners[1]]) : corners[0];
    return MeshFace._(
      corners,
      center,
      normal,
      (toward - center).unit,
      _inradius(corners, center),
    );
  }

  final List<Vec3> corners;
  final Vec3 center, normal, up;
  final double inradius;

  MeshFace scaled(double k) => MeshFace._(
    [for (final c in corners) c * k],
    center * k,
    normal,
    up,
    inradius * k,
  );

  static double _inradius(List<Vec3> corners, Vec3 center) {
    var best = double.infinity;
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final edge = corners[(i + 1) % corners.length] - a;
      best = min(best, edge.cross(center - a).length / edge.length);
    }
    return best;
  }
}
