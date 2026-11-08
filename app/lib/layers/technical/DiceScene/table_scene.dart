import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';
import 'package:amiludo/layers/technical/Dice3D/table_texture.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Dice3D/vec3.dart';
import 'package:amiludo/layers/technical/DiceScene/scene_camera.dart';

class TableScene {
  TableScene(this.camera, this.table, this.halfWidth, this.halfDepth);

  final SceneCamera camera;
  final TableTheme table;
  final double halfWidth, halfDepth;

  double get _ox => halfWidth + rimWidth;
  double get _oz => halfDepth + rimWidth;

  Path _quad(Vec3 a, Vec3 b, Vec3 c, Vec3 d) => Path()
    ..addPolygon([
      camera.project(a),
      camera.project(b),
      camera.project(c),
      camera.project(d),
    ], true);

  Path get _felt => _quad(
    Vec3(-halfWidth, 0, -halfDepth),
    Vec3(halfWidth, 0, -halfDepth),
    Vec3(halfWidth, 0, halfDepth),
    Vec3(-halfWidth, 0, halfDepth),
  );

  Path _ringTop(bool nearOnly) {
    if (nearOnly) {
      return _quad(
        Vec3(-_ox, wallHeight, halfDepth),
        Vec3(_ox, wallHeight, halfDepth),
        Vec3(_ox, wallHeight, _oz),
        Vec3(-_ox, wallHeight, _oz),
      );
    }
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(
        _quad(
          Vec3(-_ox, wallHeight, -_oz),
          Vec3(_ox, wallHeight, -_oz),
          Vec3(_ox, wallHeight, _oz),
          Vec3(-_ox, wallHeight, _oz),
        ),
        Offset.zero,
      )
      ..addPath(
        _quad(
          Vec3(-halfWidth, wallHeight, -halfDepth),
          Vec3(halfWidth, wallHeight, -halfDepth),
          Vec3(halfWidth, wallHeight, halfDepth),
          Vec3(-halfWidth, wallHeight, halfDepth),
        ),
        Offset.zero,
      );
  }

  void paintBack(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = darken(table.rim, 0.55),
    );
    final top = _ringTop(false);
    final bounds = top.getBounds();
    canvas.drawPath(
      top,
      Paint()
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          [lighten(table.rim, 0.22), table.rim, darken(table.rim, 0.15)],
          const [0, 0.5, 1],
        ),
    );
    _innerWalls(canvas);
    _feltSurface(canvas);
  }

  void _innerWalls(Canvas canvas) {
    final shade = darken(table.rim, 0.3);
    final far = _quad(
      Vec3(-halfWidth, 0, -halfDepth),
      Vec3(halfWidth, 0, -halfDepth),
      Vec3(halfWidth, wallHeight, -halfDepth),
      Vec3(-halfWidth, wallHeight, -halfDepth),
    );
    final left = _quad(
      Vec3(-halfWidth, 0, -halfDepth),
      Vec3(-halfWidth, 0, halfDepth),
      Vec3(-halfWidth, wallHeight, halfDepth),
      Vec3(-halfWidth, wallHeight, -halfDepth),
    );
    final right = _quad(
      Vec3(halfWidth, 0, -halfDepth),
      Vec3(halfWidth, 0, halfDepth),
      Vec3(halfWidth, wallHeight, halfDepth),
      Vec3(halfWidth, wallHeight, -halfDepth),
    );
    for (final (path, tone) in [
      (far, shade),
      (left, darken(table.rim, 0.1)),
      (right, darken(table.rim, 0.42)),
    ]) {
      final b = path.getBounds();
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(b.bottomCenter, b.topCenter, [
            darken(tone, 0.35),
            lighten(tone, 0.08),
          ]),
      );
    }
  }

  void _feltSurface(Canvas canvas) {
    final felt = _felt;
    final b = felt.getBounds();
    canvas.save();
    canvas.clipPath(felt);
    canvas.drawPath(
      felt,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(b.center.dx, b.top + b.height * 0.42),
          b.longestSide * 0.7,
          [lighten(table.center, 0.1), table.center, table.edge],
          const [0, 0.55, 1],
        ),
    );
    canvas.translate(b.left, b.top);
    if (table.id == 'wood') {
      paintPlanks(canvas, b.size, table.edge);
    } else {
      paintWeave(canvas, b.size, table.id == 'light');
    }
    canvas.translate(-b.left, -b.top);
    final dark = table.id == 'light' ? 0.22 : 0.5;
    canvas.drawPath(
      felt,
      Paint()
        ..shader = ui.Gradient.radial(
          b.center,
          b.longestSide * 0.62,
          [const Color(0x00000000), Color.fromRGBO(0, 0, 0, dark)],
          const [0.5, 1],
        ),
    );
    canvas.drawPath(
      felt,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = camera.focal * 0.5
        ..color = const Color(0x66000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, camera.focal * 0.3),
    );
    canvas.restore();
  }

  void paintFront(Canvas canvas) {
    final face = _quad(
      Vec3(-_ox, 0, _oz),
      Vec3(_ox, 0, _oz),
      Vec3(_ox, wallHeight, _oz),
      Vec3(-_ox, wallHeight, _oz),
    );
    final fb = face.getBounds();
    canvas.drawPath(
      face,
      Paint()
        ..shader = ui.Gradient.linear(fb.topCenter, fb.bottomCenter, [
          darken(table.rim, 0.2),
          darken(table.rim, 0.6),
        ]),
    );
    final top = _ringTop(true);
    final b = top.getBounds();
    canvas.drawPath(
      top,
      Paint()
        ..shader = ui.Gradient.linear(b.topCenter, b.bottomCenter, [
          table.rim,
          lighten(table.rim, 0.28),
        ]),
    );
    canvas.drawPath(
      top,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = lighten(table.rim, 0.45).withValues(alpha: 0.6),
    );
  }
}
