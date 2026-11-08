import 'dart:math';

import 'package:flutter/material.dart';

class ParchmentPalette {
  const ParchmentPalette._();
  static const sea = Color(0xff8fb8b5);
  static const land = Color(0xffe6d3a3);
  static const relief = Color(0xffb98a4e);
  static const ink = Color(0xff3a2a1b);
  static const gold = Color(0xffd4a017);
  static const red = Color(0xffb5392e);
}

abstract final class ParchmentSheet {
  static void paintBase(Canvas canvas, Rect sheet) {
    canvas.drawRect(sheet, Paint()..color = ParchmentPalette.land);
    final random = Random(11);
    final fibre = Paint()
      ..color = ParchmentPalette.relief.withValues(alpha: .16)
      ..strokeWidth = .8;
    for (var i = 0; i < 90; i++) {
      final x = sheet.left + random.nextDouble() * sheet.width;
      final y = sheet.top + random.nextDouble() * sheet.height;
      final len = 10 + random.nextDouble() * 26;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + len, y + random.nextDouble() * 4),
        fibre,
      );
    }
    final crease = Paint()
      ..color = ParchmentPalette.ink.withValues(alpha: .1)
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(sheet.topCenter, sheet.bottomCenter, crease)
      ..drawLine(sheet.centerLeft, sheet.centerRight, crease);
    canvas.drawRect(
      sheet,
      Paint()
        ..shader = RadialGradient(
          radius: .95,
          colors: [
            ParchmentPalette.relief.withValues(alpha: 0),
            ParchmentPalette.relief.withValues(alpha: .45),
          ],
          stops: const [.6, 1],
        ).createShader(sheet),
    );
  }

  static void paintFrame(Canvas canvas, Rect sheet) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..color = ParchmentPalette.ink.withValues(alpha: .8);
    canvas
      ..drawRect(sheet.deflate(6), line..strokeWidth = 2)
      ..drawRect(sheet.deflate(11), line..strokeWidth = .8);
    _rose(canvas, Offset(sheet.right - 44, sheet.bottom - 44), 26);
  }

  static void _rose(Canvas canvas, Offset c, double r) {
    final ink = Paint()..color = ParchmentPalette.ink;
    final red = Paint()..color = ParchmentPalette.red;
    for (var i = 0; i < 4; i++) {
      final a = i * pi / 2 - pi / 2;
      final tip = c + Offset(cos(a), sin(a)) * r;
      final left = c + Offset(cos(a - .35), sin(a - .35)) * r * .28;
      final right = c + Offset(cos(a + .35), sin(a + .35)) * r * .28;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(left.dx, left.dy)
          ..lineTo(c.dx, c.dy)
          ..lineTo(right.dx, right.dy)
          ..close(),
        i == 0 ? red : ink,
      );
    }
    canvas.drawCircle(
      c,
      r * .55,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = ParchmentPalette.ink
        ..strokeWidth = 1,
    );
  }
}
