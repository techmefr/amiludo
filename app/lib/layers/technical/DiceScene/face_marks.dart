import 'dart:math';

import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DicePhysics/convex_shape.dart';
import 'package:amiludo/layers/technical/DicePhysics/die_body.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';

const double _box = 100;
const double _fill = 1.45;

final Map<String, TextPainter> _cache = {};

TextPainter _text(String text, Color color) {
  final size = min(66.0, 150 / max(1, text.length));
  return _cache.putIfAbsent('$text|${color.toARGB32()}', () {
    if (_cache.length > 400) _cache.clear();
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  });
}

const _pips = {
  1: [Offset(0, 0)],
  2: [Offset(-1, -1), Offset(1, 1)],
  3: [Offset(-1, -1), Offset(0, 0), Offset(1, 1)],
  4: [Offset(-1, -1), Offset(1, -1), Offset(-1, 1), Offset(1, 1)],
  5: [Offset(-1, -1), Offset(1, -1), Offset(0, 0), Offset(-1, 1), Offset(1, 1)],
  6: [
    Offset(-1, -1),
    Offset(1, -1),
    Offset(-1, 0),
    Offset(1, 0),
    Offset(-1, 1),
    Offset(1, 1),
  ],
};

Matrix4 faceMatrix(SceneCamera cam, DieBody body, ShapeFace face) {
  final mesh = face.face;
  final across = body.rot.rotate(mesh.normal.cross(-mesh.up));
  final down = body.rot.rotate(-mesh.up);
  final normal = body.normalOf(face);
  final k = mesh.inradius * body.size * _fill / _box;
  final origin = body.toWorld(face.center) + normal * 0.004;
  final model = Matrix4(
    across.x * k,
    across.y * k,
    across.z * k,
    0,
    down.x * k,
    down.y * k,
    down.z * k,
    0,
    normal.x * k,
    normal.y * k,
    normal.z * k,
    0,
    origin.x,
    origin.y,
    origin.z,
    1,
  );
  return cam.viewProjection.multiplied(model);
}

void paintMark(
  Canvas canvas,
  SceneCamera cam,
  DieBody body,
  ShapeFace face, {
  required String text,
  required Color ink,
  required Color glint,
  required double alpha,
  bool pips = false,
}) {
  canvas.save();
  canvas.transform(faceMatrix(cam, body, face).storage);
  final fade = alpha.clamp(0.0, 1.0);
  if (pips &&
      int.tryParse(text) != null &&
      _pips.containsKey(int.parse(text))) {
    for (final p in _pips[int.parse(text)]!) {
      final at = Offset(p.dx * 27, p.dy * 27);
      canvas.drawCircle(
        at + const Offset(1.4, 1.8),
        11.5,
        Paint()..color = glint.withValues(alpha: 0.4 * fade),
      );
      canvas.drawCircle(at, 11.5, Paint()..color = ink.withValues(alpha: fade));
    }
  } else {
    final back = _text(text, glint.withValues(alpha: 0.45 * fade));
    final front = _text(text, ink.withValues(alpha: fade));
    back.paint(canvas, Offset(-back.width / 2 + 1.6, -back.height / 2 + 2));
    front.paint(canvas, Offset(-front.width / 2, -front.height / 2));
    if (text == '6' || text == '9') {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(0, front.height / 2 + 4),
          width: front.width * 0.9,
          height: 6,
        ),
        Paint()..color = ink.withValues(alpha: fade),
      );
    }
  }
  canvas.restore();
}

double facingOf(SceneCamera cam, DieBody body, ShapeFace face) {
  final center = body.toWorld(face.center);
  final n = body.normalOf(face);
  return n.dot(cam.toEye(center));
}

Vec3 centerOf(DieBody body, ShapeFace face) => body.toWorld(face.center);
