import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/mesh_face.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';

final double _phi = (1 + sqrt(5)) / 2;

List<MeshFace> tetrahedron() {
  const v = [Vec3(1, 1, 1), Vec3(1, -1, -1), Vec3(-1, 1, -1), Vec3(-1, -1, 1)];
  return [
    for (var i = 0; i < 4; i++)
      MeshFace.fromCorners([
        for (var j = 0; j < 4; j++)
          if (j != i) v[j],
      ]),
  ];
}

List<MeshFace> cube() {
  const axes = [
    Vec3(1, 0, 0),
    Vec3(0, 1, 0),
    Vec3(0, 0, 1),
    Vec3(0, 0, -1),
    Vec3(0, -1, 0),
    Vec3(-1, 0, 0),
  ];
  return [
    for (final n in axes)
      MeshFace.fromCorners([
        for (final s in const [-1.0, 1.0])
          for (final t in const [-1.0, 1.0]) _onFace(n, s, t),
      ], edgeUp: true),
  ];
}

Vec3 _onFace(Vec3 n, double s, double t) {
  final a = n.x != 0 ? const Vec3(0, 1, 0) : const Vec3(1, 0, 0);
  final b = n.cross(a);
  return n + a * s + b * t;
}

List<MeshFace> octahedron() => [
  for (var i = 0; i < 8; i++)
    MeshFace.fromCorners([
      Vec3(i & 1 == 0 ? 1 : -1, 0, 0),
      Vec3(0, i & 2 == 0 ? 1 : -1, 0),
      Vec3(0, 0, i & 4 == 0 ? 1 : -1),
    ]),
];

List<Vec3> _icosaVertices() => [
  for (final a in const [-1.0, 1.0])
    for (final b in const [-1.0, 1.0]) ...[
      Vec3(0, a, b * _phi),
      Vec3(a, b * _phi, 0),
      Vec3(b * _phi, 0, a),
    ],
];

List<List<int>> _icosaTriangles(List<Vec3> v) => [
  for (var i = 0; i < v.length; i++)
    for (var j = i + 1; j < v.length; j++)
      for (var k = j + 1; k < v.length; k++)
        if (_isEdge(v[i], v[j]) && _isEdge(v[j], v[k]) && _isEdge(v[i], v[k]))
          [i, j, k],
];

bool _isEdge(Vec3 a, Vec3 b) => ((a - b).length - 2).abs() < 1e-6;

List<MeshFace> icosahedron() {
  final v = _icosaVertices();
  return [
    for (final t in _icosaTriangles(v))
      MeshFace.fromCorners([for (final i in t) v[i]]),
  ];
}

List<MeshFace> dodecahedron() {
  final v = _icosaVertices();
  final triangles = _icosaTriangles(v);
  final centers = [
    for (final t in triangles) Vec3.mean([for (final i in t) v[i]]).unit,
  ];
  return [
    for (var i = 0; i < v.length; i++)
      MeshFace.fromCorners([
        for (var f = 0; f < triangles.length; f++)
          if (triangles[f].contains(i)) centers[f],
      ]),
  ];
}

List<MeshFace> trapezohedron([int n = 5]) {
  final cosine = cos(pi / n);
  final a = n == 5 ? 0.1 : 0.95 * (1 - cosine) / (1 + cosine);
  final apex = Vec3(0, 0, a * (1 + cosine) / (1 - cosine));
  Vec3 ring(int i, double z) => Vec3(cos(i * pi / n), sin(i * pi / n), z);
  Vec3 upper(int k) => ring(2 * k, a);
  Vec3 lower(int k) => ring(2 * k + 1, -a);
  final top = [
    for (var k = 0; k < n; k++)
      MeshFace.fromCorners([apex, upper(k), lower(k), upper(k + 1)]),
  ];
  final bottom = [
    for (var k = 0; k < n; k++)
      MeshFace.fromCorners([-apex, lower(k), upper(k + 1), lower(k + 1)]),
  ];
  if (n != 5) return [...top, ...bottom];
  return [...top, for (var k = 4; k >= 0; k--) bottom[(k + 2) % 5]];
}

List<MeshFace> prism(int n, double length) {
  Vec3 corner(int i, double z) =>
      Vec3(cos(2 * pi * i / n), sin(2 * pi * i / n), z);
  return [
    for (var i = 0; i < n; i++)
      MeshFace.fromCorners([
        corner(i, -length),
        corner(i + 1, -length),
        corner(i + 1, length),
        corner(i, length),
      ]),
    MeshFace.fromCorners([for (var i = 0; i < n; i++) corner(i, length)]),
    MeshFace.fromCorners([for (var i = 0; i < n; i++) corner(i, -length)]),
  ];
}

List<MeshFace> ballFaces(int count) {
  final half = min(0.8, sqrt(4 * pi / count) / 2 * 0.95);
  final distance = sqrt(1 - half * half);
  return [
    for (var i = 0; i < count; i++) _disc(_fibonacci(i, count), half, distance),
  ];
}

Vec3 _fibonacci(int i, int count) {
  final y = 1 - 2 * (i + 0.5) / count;
  final r = sqrt(1 - y * y);
  final turn = i * pi * (3 - sqrt(5));
  return Vec3(cos(turn) * r, y, sin(turn) * r);
}

MeshFace _disc(Vec3 normal, double half, double distance) {
  final a = (normal.y.abs() > 0.9 ? const Vec3(1, 0, 0) : const Vec3(0, 1, 0))
      .cross(normal)
      .unit;
  final b = normal.cross(a);
  return MeshFace.fromCorners([
    for (var i = 0; i < 8; i++)
      normal * distance +
          a * (cos(i * pi / 4) * half) +
          b * (sin(i * pi / 4) * half),
  ]);
}
