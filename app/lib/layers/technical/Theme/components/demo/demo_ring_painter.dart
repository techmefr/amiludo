import 'dart:math' as math;

import 'package:flutter/material.dart';

class DemoRingPainter extends CustomPainter {
  const DemoRingPainter({required this.remaining, required this.color});

  final double remaining;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = math.min(size.width, size.height) * .74;
    final stroke = diameter * .11;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: diameter,
      height: diameter,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: .22),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * remaining,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(DemoRingPainter old) =>
      old.remaining != remaining || old.color != color;
}
