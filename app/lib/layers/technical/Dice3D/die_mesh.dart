import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/mesh_face.dart';
import 'package:amiludo/layers/technical/Dice3D/solids.dart';

const _longPrism = 1.7;
const _stubbyPrism = 0.95;
const _prismSides = 3;

class DieMesh {
  DieMesh._(this.faces, this.ball, {this.caps = const [], this.scale = 1});

  factory DieMesh.forSides(int sides) =>
      _cache.putIfAbsent(sides, () => _build(sides));

  final List<MeshFace> faces, caps;
  final bool ball;
  final double scale;

  static final Map<int, DieMesh> _cache = {};

  List<MeshFace> get drawn => [...faces, ...caps];

  int faceOf(int value) => scale == 1
      ? (value - 1).clamp(0, faces.length - 1)
      : (value - 1) % faces.length;

  int valueOf(int face) => ((face + 1) * scale).round();

  static DieMesh _build(int sides) {
    final solid = switch (sides) {
      3 => prism(_prismSides, _longPrism),
      4 => tetrahedron(),
      5 => prism(_prismSides, _stubbyPrism),
      6 => cube(),
      8 => octahedron(),
      10 || 1000 => trapezohedron(),
      12 => dodecahedron(),
      16 => trapezohedron(8),
      20 => icosahedron(),
      24 => trapezohedron(12),
      30 => trapezohedron(15),
      60 => trapezohedron(30),
      _ => null,
    };
    if (solid == null) return DieMesh._(ballFaces(max(sides, 2)), true);
    var reach = 0.0;
    for (final face in solid) {
      for (final corner in face.corners) {
        reach = max(reach, corner.length);
      }
    }
    final fitted = [for (final f in solid) f.scaled(1 / reach)];
    final count = sides == 3 ? sides : (sides == 1000 ? 10 : fitted.length);
    return DieMesh._(
      fitted.sublist(0, count),
      false,
      caps: fitted.sublist(count),
      scale: sides / count,
    );
  }
}
