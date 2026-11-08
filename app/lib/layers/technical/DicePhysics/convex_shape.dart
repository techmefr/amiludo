import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/mesh_face.dart';
import 'package:amiludo/layers/technical/Dice3D/solids.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

class ShapeFace {
  const ShapeFace(this.face, this.value);

  final MeshFace face;
  final int value;

  Vec3 get normal => face.normal;
  Vec3 get center => face.center;
  bool get valued => value > 0;
  double get offset => face.normal.dot(face.center);
}

class ConvexShape {
  ConvexShape._(this.sides, this.faces, this.vertices, this.sphere);

  factory ConvexShape.forSides(int sides) =>
      _cache.putIfAbsent(sides, () => _build(sides));

  final int sides;
  final List<ShapeFace> faces;
  final List<Vec3> vertices;
  final bool sphere;

  static final Map<int, ConvexShape> _cache = {};

  List<ShapeFace> get valued => [
    for (final f in faces)
      if (f.valued) f,
  ];

  List<Vec3> get samples => _samples ??= _sampled();

  List<Vec3>? _samples;

  List<Vec3> _sampled() {
    final points = [...vertices];
    for (final f in faces) {
      points.add(f.center);
      final c = f.face.corners;
      for (var i = 0; i < c.length; i++) {
        points.add((c[i] + c[(i + 1) % c.length]) * 0.5);
      }
    }
    return points;
  }

  bool get readsDownward => sides == 4;

  bool get hasStableFaces => !sphere;

  static ConvexShape _build(int sides) {
    if (sides == 2) return _coin();
    final mesh = DieMesh.forSides(sides);
    final faces = [
      for (var i = 0; i < mesh.faces.length; i++)
        ShapeFace(mesh.faces[i], mesh.valueOf(i)),
      for (final cap in mesh.caps) ShapeFace(cap, 0),
    ];
    return ConvexShape._(
      sides,
      faces,
      mesh.ball ? const [] : _unique(faces),
      mesh.ball,
    );
  }

  static ConvexShape _coin() {
    final raw = prism(16, 0.14);
    final top = raw[raw.length - 2], bottom = raw.last;
    final faces = [
      ShapeFace(top.scaled(1 / _reach(raw)), 1),
      ShapeFace(bottom.scaled(1 / _reach(raw)), 2),
      for (var i = 0; i < raw.length - 2; i++)
        ShapeFace(raw[i].scaled(1 / _reach(raw)), 0),
    ];
    return ConvexShape._(2, faces, _unique(faces), false);
  }

  static double _reach(List<MeshFace> solid) {
    var reach = 0.0;
    for (final f in solid) {
      for (final c in f.corners) {
        reach = max(reach, c.length);
      }
    }
    return reach;
  }

  static List<Vec3> _unique(List<ShapeFace> faces) {
    final seen = <String, Vec3>{};
    for (final f in faces) {
      for (final c in f.face.corners) {
        seen.putIfAbsent(
          '${(c.x * 1e5).round()}|${(c.y * 1e5).round()}|${(c.z * 1e5).round()}',
          () => c,
        );
      }
    }
    return seen.values.toList();
  }
}
