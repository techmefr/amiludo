import 'dart:ui';

import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

const Vec3 _towardLight = Vec3(-0.35, -0.55, -0.75);
const double _minFacing = 0.02;
const double _contentFill = 1.35;

class ProjectedFace {
  const ProjectedFace({
    required this.index,
    required this.outline,
    required this.center,
    required this.axisX,
    required this.axisY,
    required this.facing,
    required this.light,
    required this.contentSize,
  });

  final int index;
  final List<Offset> outline;
  final Offset center, axisX, axisY;
  final double facing, light, contentSize;
}

class DieProjection {
  const DieProjection._();

  static Offset _flat(Vec3 v, double radius) =>
      Offset(v.x * radius, v.y * radius);

  static List<ProjectedFace> faces(DieMesh mesh, Mat3 pose, double radius) {
    final light = _towardLight.unit;
    final shown = <ProjectedFace>[];
    final drawn = mesh.drawn;
    for (var i = 0; i < drawn.length; i++) {
      final f = drawn[i];
      final normal = pose.apply(f.normal);
      if (-normal.z < _minFacing) continue;
      final across = pose.apply(f.normal.cross(-f.up));
      final down = pose.apply(-f.up);
      final unit = (f.inradius * _contentFill * radius);
      shown.add(
        ProjectedFace(
          index: i,
          outline: [for (final c in f.corners) _flat(pose.apply(c), radius)],
          center: _flat(pose.apply(f.center), radius),
          axisX: _flat(across, 1),
          axisY: _flat(down, 1),
          facing: -normal.z,
          light: normal.dot(light).clamp(0.0, 1.0),
          contentSize: unit,
        ),
      );
    }
    shown.sort((a, b) => a.facing.compareTo(b.facing));
    return shown;
  }

  static Color shade(Color base, double light) {
    final t = 0.4 + light * 0.9;
    return t <= 1
        ? Color.lerp(const Color(0xFF000000), base, t)!
        : Color.lerp(base, const Color(0xFFFFFFFF), (t - 1) * 0.6)!;
  }
}
