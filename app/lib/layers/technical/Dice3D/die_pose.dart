import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/die_mesh.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

class DiePose {
  const DiePose._();

  static const double _pitch = -0.42, _yaw = 0.5, _share = 0.35;

  static Mat3 view(DieMesh mesh, int face) {
    final scale = min(1.0, _share * _gap(mesh, face) / hypot(_pitch, _yaw));
    return Mat3.rotationX(_pitch * scale) * Mat3.rotationY(_yaw * scale);
  }

  static double hypot(double a, double b) => sqrt(a * a + b * b);

  static double _gap(DieMesh mesh, int face) {
    final normal = mesh.faces[face].normal;
    var nearest = -1.0;
    for (var i = 0; i < mesh.faces.length; i++) {
      if (i != face) nearest = max(nearest, normal.dot(mesh.faces[i].normal));
    }
    return acos(nearest.clamp(-1.0, 1.0));
  }

  static Mat3 facing(DieMesh mesh, int face) {
    final f = mesh.faces[face];
    final down = -f.up;
    final right = f.normal.cross(down);
    return Mat3(right, down, right.cross(down));
  }

  static Mat3 resting(DieMesh mesh, int face) =>
      view(mesh, face) * facing(mesh, face);

  static Mat3 tumbling(DieMesh mesh, int face, double flipX, double flipY) =>
      Mat3.rotationX(flipX * pi) *
      Mat3.rotationY(flipY * pi) *
      resting(mesh, face);
}
