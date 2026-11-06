import 'dart:math';

import 'package:flutter/material.dart';

class HourglassPainter extends CustomPainter {
  HourglassPainter({
    required this.upperFill,
    required this.lowerFill,
    required this.sand,
    required this.glass,
    required this.streaming,
  });

  final double upperFill, lowerFill;
  final Color sand, glass;
  final bool streaming;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, mid = h / 2, neck = w * 0.06;
    final chamber = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w / 2 + neck, mid)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..lineTo(w / 2 - neck, mid)
      ..close();
    canvas.save();
    canvas.clipPath(chamber);
    final fill = Paint()..color = sand;
    final upper = upperFill.clamp(0.0, 1.0), lower = lowerFill.clamp(0.0, 1.0);
    if (upper > 0) {
      final top = mid * (1 - upper);
      final span = (mid - top) / mid;
      final inset = (w / 2 - neck) * (1 - span);
      canvas.drawPath(
        Path()
          ..moveTo(inset, top)
          ..lineTo(w - inset, top)
          ..lineTo(w / 2 + neck, mid)
          ..lineTo(w / 2 - neck, mid)
          ..close(),
        fill,
      );
    }
    if (lower > 0) {
      final top = h - mid * lower;
      canvas.drawRect(Rect.fromLTRB(0, top, w, h), fill);
    }
    if (streaming) {
      canvas.drawRect(
        Rect.fromLTRB(w / 2 - neck / 3, mid, w / 2 + neck / 3, h - mid * lower),
        fill,
      );
    }
    canvas.restore();
    canvas.drawPath(
      chamber,
      Paint()
        ..color = glass
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2, w * 0.02)
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(HourglassPainter old) =>
      old.upperFill != upperFill ||
      old.lowerFill != lowerFill ||
      old.sand != sand ||
      old.glass != glass ||
      old.streaming != streaming;
}
