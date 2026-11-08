import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/contact.dart';
import 'package:amiludo/layers/technical/DicePhysics/convex_shape.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';

class Wall {
  const Wall(this.normal, this.offset, this.kind);

  final Vec3 normal;
  final double offset;
  final DieImpactKind kind;

  double distance(Vec3 p) => normal.dot(p) - offset;
}

class _Inside {
  const _Inside(this.depth, this.normal);

  final double depth;
  final Vec3 normal;
}

List<Contact> wallContacts(DieBody body, List<Wall> walls) {
  final found = <Contact>[];
  for (final wall in walls) {
    if (body.shape.sphere) {
      final gap = wall.distance(body.pos) - body.size;
      if (gap < 0) {
        found.add(
          Contact(
            a: body,
            b: null,
            point: body.pos - wall.normal * body.size,
            normal: wall.normal,
            depth: -gap,
            kind: wall.kind,
            friction: wall.kind == DieImpactKind.table ? 0.5 : 0.25,
            restitution: wall.kind == DieImpactKind.table ? 0.38 : 0.5,
          ),
        );
      }
      continue;
    }
    for (final p in body.worldVertices) {
      final gap = wall.distance(p);
      if (gap >= 0) continue;
      found.add(
        Contact(
          a: body,
          b: null,
          point: p,
          normal: wall.normal,
          depth: -gap,
          kind: wall.kind,
          friction: wall.kind == DieImpactKind.table ? 0.55 : 0.3,
          restitution: wall.kind == DieImpactKind.table ? 0.38 : 0.5,
        ),
      );
    }
  }
  return found;
}

List<Contact> pairContacts(DieBody a, DieBody b) {
  final reach = a.size + b.size;
  if ((a.pos - b.pos).length >= reach) return const [];
  if (a.shape.sphere && b.shape.sphere) {
    final gap = (a.pos - b.pos).length;
    final n = gap == 0 ? const Vec3(0, 1, 0) : (a.pos - b.pos).unit;
    return [
      Contact(
        a: a,
        b: b,
        point: b.pos + n * b.size,
        normal: n,
        depth: reach - gap,
        kind: DieImpactKind.die,
        restitution: 0.45,
      ),
    ];
  }
  return [..._into(a, b), ..._into(b, a)];
}

List<Contact> _into(DieBody mover, DieBody solid) {
  final points = mover.shape.sphere ? [mover.pos] : mover.samplePoints;
  final found = <Contact>[];
  for (final p in points) {
    final inside = solid.shape.sphere
        ? _insideSphere(p, solid)
        : _insideHull(p, solid, mover.shape.sphere ? mover.size : 0);
    if (inside == null) continue;
    found.add(
      Contact(
        a: mover,
        b: solid,
        point: mover.shape.sphere ? p - inside.normal * mover.size : p,
        normal: inside.normal,
        depth: inside.depth,
        kind: DieImpactKind.die,
        restitution: 0.45,
      ),
    );
  }
  return found;
}

_Inside? _insideSphere(Vec3 p, DieBody sphere) {
  final away = p - sphere.pos;
  final gap = sphere.size - away.length;
  if (gap <= 0) return null;
  return _Inside(gap, away.length == 0 ? const Vec3(0, 1, 0) : away.unit);
}

_Inside? _insideHull(Vec3 p, DieBody solid, double margin) {
  var best = -double.infinity;
  Vec3 normal = const Vec3(0, 1, 0);
  for (final ShapeFace face in solid.shape.faces) {
    final n = solid.normalOf(face);
    final dist = n.dot(p - solid.pos) - face.offset * solid.size;
    if (dist > best) {
      best = dist;
      normal = n;
    }
  }
  if (best >= margin) return null;
  return _Inside(margin - best, normal);
}
