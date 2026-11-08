import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/convex_shape.dart';
import 'package:amiludo/layers/technical/DicePhysics/quat.dart';

const Vec3 _down = Vec3(0, -1, 0);

class DieBody {
  DieBody({
    required this.shape,
    required this.pos,
    required this.rot,
    this.vel = Vec3.zero,
    this.omega = Vec3.zero,
    this.size = 1,
  });

  final ConvexShape shape;
  final double size;
  Vec3 pos, vel, omega;
  Quat rot;
  bool asleep = false;
  int still = 0;
  bool grounded = false;

  double get invMass => 1;

  double get invInertia => 1 / (0.25 * size * size);

  double get speed => vel.length;

  Vec3 toWorld(Vec3 local) => pos + rot.rotate(local * size);

  Vec3 normalOf(ShapeFace face) => rot.rotate(face.normal);

  List<Vec3> get worldVertices => [for (final v in shape.vertices) toWorld(v)];

  List<Vec3> get samplePoints => [for (final v in shape.samples) toWorld(v)];

  ShapeFace bestFace(Vec3 toward) {
    var best = shape.valued.first;
    var score = -2.0;
    for (final face in shape.valued) {
      final s = normalOf(face).dot(toward);
      if (s > score) {
        score = s;
        best = face;
      }
    }
    return best;
  }

  double alignment() => normalOf(bestFace(_down)).dot(_down);

  Vec3 tipAxis() => normalOf(bestFace(_down)).cross(_down);

  int get value =>
      bestFace(shape.readsDownward ? _down : const Vec3(0, 1, 0)).value;

  void sleep() {
    vel = Vec3.zero;
    omega = Vec3.zero;
    asleep = true;
  }

  void wake() {
    asleep = false;
    still = 0;
  }

  double get energy => speed + omega.length * 0.5;
}
