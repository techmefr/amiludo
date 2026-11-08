import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/die_finish.dart';
import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/convex_shape.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';
import 'package:amiludo/layers/technical/DiceScene/face_marks.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_light.dart';

class SceneDie {
  const SceneDie({
    required this.body,
    required this.base,
    required this.skin,
    required this.label,
    this.pips = false,
    this.ink,
  });

  final DieBody body;
  final Color base;
  final DieSkin skin;
  final String? Function(int value) label;
  final bool pips;
  final Color? ink;
}

class _Visible {
  _Visible(this.face, this.depth, this.facing, this.normal, this.center);

  final ShapeFace face;
  final double depth, facing;
  final Vec3 normal, center;
}

Offset _towardLight(SceneCamera cam, Vec3 at) {
  final d = cam.project(at + lightDirection) - cam.project(at);
  return d.distance == 0 ? const Offset(-1, -1) : d / d.distance;
}

void paintDie(Canvas canvas, SceneCamera cam, SceneDie die) {
  final body = die.body;
  if (body.shape.sphere) return _ball(canvas, cam, die);
  final seen = <_Visible>[];
  for (final face in body.shape.faces) {
    final center = body.toWorld(face.center);
    final normal = body.normalOf(face);
    final facing = normal.dot(cam.toEye(center));
    if (facing <= 0) continue;
    seen.add(_Visible(face, cam.depth(center), facing, normal, center));
  }
  seen.sort((a, b) => b.depth.compareTo(a.depth));
  for (final v in seen) {
    _face(canvas, cam, die, v);
  }
}

void _face(Canvas canvas, SceneCamera cam, SceneDie die, _Visible v) {
  final body = die.body;
  final corners = [
    for (final c in v.face.face.corners) cam.project(body.toWorld(c)),
  ];
  final bounds = Path()..addPolygon(corners, true);
  final extent = bounds.getBounds().shortestSide;
  final soft = die.skin.finish == DieFinish.soft;
  final path = roundedPolygon(corners, extent * (soft ? 0.2 : 0.07));
  final color = lit(die.base, v.normal);
  paintFacet(canvas, path, color, die.skin);
  if (soft) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = extent * 0.1
        ..color = color,
    );
  }
  paintBevel(canvas, path, color, max(1.2, extent * (soft ? 0.09 : 0.05)));
  final shine = specularOf(v.normal, cam.toEye(v.center), die.skin.finish);
  if (shine > 0.02) _glint(canvas, cam, path, v, shine);
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1
      ..color = darken(color, 0.6).withValues(alpha: soft ? 0.25 : 0.7),
  );
  final text = v.face.valued ? die.label(v.face.value) : null;
  if (text != null && v.facing > 0.18) {
    final stamp = _stamp(die, color);
    paintMark(
      canvas,
      cam,
      body,
      v.face,
      text: text,
      ink: stamp.ink,
      glint: stamp.glint,
      alpha: ((v.facing - 0.18) / 0.4).clamp(0.0, 1.0),
      pips: die.pips && body.shape.sides == 6,
    );
  }
}

({Color ink, Color glint}) _stamp(SceneDie die, Color shaded) {
  final dark = die.base.computeLuminance() < 0.25;
  return (
    ink: die.ink ?? die.skin.pip,
    glint: dark ? lighten(shaded, 0.5) : lighten(shaded, 0.7),
  );
}

void _glint(Canvas canvas, SceneCamera cam, Path path, _Visible v, double k) {
  final b = path.getBounds();
  final spot = b.center + _towardLight(cam, v.center) * b.shortestSide * 0.2;
  final reach = b.shortestSide * 0.62;
  canvas.save();
  canvas.clipPath(path);
  canvas.drawCircle(
    spot,
    reach,
    Paint()
      ..shader = ui.Gradient.radial(spot, reach, [
        Color.fromRGBO(255, 255, 255, k.clamp(0.0, 0.85)),
        const Color(0x00FFFFFF),
      ]),
  );
  canvas.restore();
}

void _ball(Canvas canvas, SceneCamera cam, SceneDie die) {
  final body = die.body;
  final c = cam.project(body.pos);
  final r = cam.scaleAt(body.pos) * body.size;
  final focus = c + _towardLight(cam, body.pos) * r * 0.38;
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = ui.Gradient.radial(
        focus,
        r * 1.45,
        [lighten(die.base, 0.32), die.base, darken(die.base, 0.62)],
        const [0, 0.5, 1],
      ),
  );
  final shine = die.skin.finish == DieFinish.matte ? 0.12 : 0.5;
  canvas.drawCircle(
    focus,
    r * 0.5,
    Paint()
      ..shader = ui.Gradient.radial(focus, r * 0.5, [
        Color.fromRGBO(255, 255, 255, shine),
        const Color(0x00FFFFFF),
      ]),
  );
  final stamp = _stamp(die, die.base);
  for (final face in body.shape.valued) {
    final facing = facingOf(cam, body, face);
    final text = die.label(face.value);
    if (facing < 0.5 || text == null) continue;
    paintMark(
      canvas,
      cam,
      body,
      face,
      text: text,
      ink: stamp.ink,
      glint: stamp.glint,
      alpha: ((facing - 0.5) / 0.3).clamp(0.0, 1.0),
    );
  }
}
