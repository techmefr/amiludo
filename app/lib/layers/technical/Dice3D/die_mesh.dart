import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/mesh_face.dart';
import 'package:amiludo/layers/technical/Dice3D/solids.dart';

class DieMesh {
  DieMesh._(this.faces, this.ball);

  factory DieMesh.forSides(int sides) =>
      _cache.putIfAbsent(sides, () => _build(sides));

  final List<MeshFace> faces;
  final bool ball;

  static final Map<int, DieMesh> _cache = {};

  static DieMesh _build(int sides) {
    final solid = switch (sides) {
      4 => tetrahedron(),
      6 => cube(),
      8 => octahedron(),
      10 => trapezohedron(),
      12 => dodecahedron(),
      20 => icosahedron(),
      _ => null,
    };
    if (solid == null) return DieMesh._(ballFaces(max(sides, 2)), true);
    var reach = 0.0;
    for (final face in solid) {
      for (final corner in face.corners) {
        reach = max(reach, corner.length);
      }
    }
    return DieMesh._([for (final f in solid) f.scaled(1 / reach)], false);
  }
}
