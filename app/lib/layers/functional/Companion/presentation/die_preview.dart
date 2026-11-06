import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

int _corners(DieShape shape) => switch (shape) {
  DieShape.d4 => 3,
  DieShape.d6 => 4,
  DieShape.d8 => 4,
  DieShape.d10 => 5,
  DieShape.d12 => 5,
  DieShape.d20 => 6,
  _ => 0,
};

class DieSilhouette extends CustomPainter {
  DieSilhouette(this.shape, this.color, this.edge);
  final DieShape shape;
  final Color color, edge;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 2;
    final n = _corners(shape);
    if (n == 0) {
      final rect = Rect.fromCircle(center: c, radius: r);
      final path = Path();
      if (shape == DieShape.coin) {
        path.addOval(rect);
      } else {
        path.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r * 0.45)));
      }
      canvas.drawPath(path, fill);
      canvas.drawPath(path, line);
      return;
    }
    final turn = shape == DieShape.d8 ? math.pi / 4 : -math.pi / 2;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final a = turn + i * 2 * math.pi / n;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(DieSilhouette old) =>
      old.shape != shape || old.color != color || old.edge != edge;
}

class DiePreview extends StatelessWidget {
  const DiePreview({
    super.key,
    required this.design,
    this.size = 96,
    this.faceIndex = 0,
  });
  final DieDesign design;
  final double size;
  final int faceIndex;

  @override
  Widget build(BuildContext context) {
    final body = Color(design.color);
    return Semantics(
      label: '${design.name}, ${design.sides}',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: DieSilhouette(design.shape, body, readableOn(body)),
          child: DieFaceView(
            face: design.faces[faceIndex.clamp(0, design.faces.length - 1)],
            body: body,
            size: size,
          ),
        ),
      ),
    );
  }
}
