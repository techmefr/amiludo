import 'dart:math';

class Vec3 {
  const Vec3(this.x, this.y, this.z);

  final double x, y, z;

  static const zero = Vec3(0, 0, 0);

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);

  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);

  Vec3 operator -() => Vec3(-x, -y, -z);

  Vec3 operator *(double k) => Vec3(x * k, y * k, z * k);

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;

  Vec3 cross(Vec3 o) =>
      Vec3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  double get length => sqrt(dot(this));

  Vec3 get unit {
    final l = length;
    return l == 0 ? this : this * (1 / l);
  }

  static Vec3 mean(List<Vec3> points) {
    var sum = zero;
    for (final p in points) {
      sum = sum + p;
    }
    return sum * (1 / points.length);
  }
}

class Mat3 {
  const Mat3(this.r0, this.r1, this.r2);

  final Vec3 r0, r1, r2;

  static const identity = Mat3(Vec3(1, 0, 0), Vec3(0, 1, 0), Vec3(0, 0, 1));

  factory Mat3.rotationX(double a) => Mat3(
    const Vec3(1, 0, 0),
    Vec3(0, cos(a), -sin(a)),
    Vec3(0, sin(a), cos(a)),
  );

  factory Mat3.rotationY(double a) => Mat3(
    Vec3(cos(a), 0, sin(a)),
    const Vec3(0, 1, 0),
    Vec3(-sin(a), 0, cos(a)),
  );

  factory Mat3.rotationZ(double a) => Mat3(
    Vec3(cos(a), -sin(a), 0),
    Vec3(sin(a), cos(a), 0),
    const Vec3(0, 0, 1),
  );

  Vec3 apply(Vec3 v) => Vec3(r0.dot(v), r1.dot(v), r2.dot(v));

  Mat3 operator *(Mat3 o) {
    final c0 = Vec3(o.r0.x, o.r1.x, o.r2.x);
    final c1 = Vec3(o.r0.y, o.r1.y, o.r2.y);
    final c2 = Vec3(o.r0.z, o.r1.z, o.r2.z);
    Vec3 row(Vec3 r) => Vec3(r.dot(c0), r.dot(c1), r.dot(c2));
    return Mat3(row(r0), row(r1), row(r2));
  }
}
