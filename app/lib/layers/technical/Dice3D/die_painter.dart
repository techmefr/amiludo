import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/die_projection.dart';

class DiePainter extends CustomPainter {
  const DiePainter({
    required this.faces,
    required this.base,
    required this.edge,
    required this.radius,
    required this.ball,
  });

  final List<ProjectedFace> faces;
  final Color base, edge;
  final double radius;
  final bool ball;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    if (ball) {
      canvas.drawCircle(
        Offset.zero,
        radius * 0.99,
        Paint()..color = DieProjection.shade(base, 0.2),
      );
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.2
      ..color = edge;
    for (final face in faces) {
      final path = Path()..addPolygon(face.outline, true);
      canvas.drawPath(
        path,
        Paint()..color = DieProjection.shade(base, face.light),
      );
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(DiePainter old) =>
      old.faces != faces ||
      old.base != base ||
      old.edge != edge ||
      old.radius != radius ||
      old.ball != ball;
}
