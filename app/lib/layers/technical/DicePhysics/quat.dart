import 'dart:math';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

class Quat {
  const Quat(this.w, this.x, this.y, this.z);

  factory Quat.random(SeededRandom rng) {
    final u1 = rng.nextDouble();
    final u2 = rng.nextDouble() * 2 * pi;
    final u3 = rng.nextDouble() * 2 * pi;
    final a = sqrt(1 - u1), b = sqrt(u1);
    return Quat(b * cos(u3), a * sin(u2), a * cos(u2), b * sin(u3));
  }

  static const identity = Quat(1, 0, 0, 0);

  final double w, x, y, z;

  Quat operator *(Quat o) => Quat(
    w * o.w - x * o.x - y * o.y - z * o.z,
    w * o.x + x * o.w + y * o.z - z * o.y,
    w * o.y - x * o.z + y * o.w + z * o.x,
    w * o.z + x * o.y - y * o.x + z * o.w,
  );

  Quat get normalized {
    final l = sqrt(w * w + x * x + y * y + z * z);
    return l == 0 ? identity : Quat(w / l, x / l, y / l, z / l);
  }

  Quat integrated(Vec3 omega, double dt) {
    final spin = Quat(0, omega.x, omega.y, omega.z) * this;
    final h = 0.5 * dt;
    return Quat(
      w + spin.w * h,
      x + spin.x * h,
      y + spin.y * h,
      z + spin.z * h,
    ).normalized;
  }

  Vec3 rotate(Vec3 v) {
    final q = Vec3(x, y, z);
    final t = q.cross(v) * 2;
    return v + t * w + q.cross(t);
  }

  Mat3 get matrix {
    final cx = rotate(const Vec3(1, 0, 0));
    final cy = rotate(const Vec3(0, 1, 0));
    final cz = rotate(const Vec3(0, 0, 1));
    return Mat3(
      Vec3(cx.x, cy.x, cz.x),
      Vec3(cx.y, cy.y, cz.y),
      Vec3(cx.z, cy.z, cz.z),
    );
  }
}
