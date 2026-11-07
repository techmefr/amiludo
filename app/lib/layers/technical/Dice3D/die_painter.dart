import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/die_finish.dart';
import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';
import 'package:amiludo/layers/technical/Dice3D/die_projection.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';

class DiePainter extends CustomPainter {
  const DiePainter({
    required this.faces,
    required this.base,
    required this.skin,
    required this.radius,
    required this.ball,
    this.faceted = false,
  });

  final List<ProjectedFace> faces;
  final Color base;
  final DieSkin skin;
  final double radius;
  final bool ball, faceted;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    if (ball) _sphere(canvas);
    var brightest = 0.0;
    for (final f in faces) {
      if (f.light > brightest) brightest = f.light;
    }
    final corner = radius * 0.1;
    for (final face in faces) {
      final path = roundedPolygon(face.outline, corner);
      final tinted = faceted ? tintFacet(base, face.index) : base;
      final color = DieProjection.shade(tinted, face.light);
      paintFacet(canvas, path, color, skin);
      paintBevel(canvas, path, color, radius * 0.07);
      if (face.light == brightest) paintSpecular(canvas, path, skin);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 1
          ..color = darken(color, 0.55).withValues(alpha: 0.6),
      );
    }
  }

  void _sphere(Canvas canvas) {
    final focus = Offset(-radius * 0.3, -radius * 0.3);
    canvas.drawCircle(
      Offset.zero,
      radius * 0.99,
      Paint()
        ..shader = ui.Gradient.radial(
          focus,
          radius * 1.4,
          [lighten(base, 0.25), base, darken(base, 0.5)],
          const [0, 0.5, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(DiePainter old) =>
      old.faces != faces ||
      old.base != base ||
      old.skin != skin ||
      old.radius != radius ||
      old.ball != ball ||
      old.faceted != faceted;
}
