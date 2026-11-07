import 'dart:math';

import 'package:flutter/rendering.dart';

import 'package:amiludo/layers/technical/Dice3D/die_paths.dart';

const int _plankCount = 9;

void paintPlanks(Canvas canvas, Size size, Color tone) {
  final vanishing = Offset(size.width / 2, -size.height * 0.9);
  final spread = size.width * 1.6 / _plankCount;
  final start = size.width / 2 - spread * _plankCount / 2;
  for (var k = 0; k < _plankCount; k++) {
    final a = Offset(start + spread * k, size.height);
    final b = Offset(start + spread * (k + 1), size.height);
    final farA = Offset.lerp(a, vanishing, 0.7)!;
    final farB = Offset.lerp(b, vanishing, 0.7)!;
    final plank = Path()..addPolygon([a, farA, farB, b], true);
    final tint = (k.isEven ? lighten(tone, 0.12) : darken(tone, 0.12))
        .withValues(alpha: 0.22);
    canvas.drawPath(plank, Paint()..color = tint);
    canvas.drawLine(
      a,
      farA,
      Paint()
        ..color = darken(tone, 0.5).withValues(alpha: 0.35)
        ..strokeWidth = 1.2,
    );
  }
  final grain = Random(11);
  final paint = Paint()
    ..color = darken(tone, 0.4).withValues(alpha: 0.12)
    ..strokeWidth = 1;
  for (var i = 0; i < 38; i++) {
    final y = grain.nextDouble() * size.height;
    final x = grain.nextDouble() * size.width;
    canvas.drawLine(Offset(x, y), Offset(x + 30 + grain.nextDouble() * 50, y), paint);
  }
}

void paintWeave(Canvas canvas, Size size, bool light) {
  final ink = light ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  final line = Paint()
    ..color = ink.withValues(alpha: 0.035)
    ..strokeWidth = 1;
  const rows = 34;
  for (var i = 0; i < rows; i++) {
    final t = pow(i / rows, 1.7).toDouble();
    final y = size.height * t;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
  }
  final noise = Random(5);
  final dot = Paint()..color = ink.withValues(alpha: 0.06);
  final count = (size.width * size.height / 260).clamp(120, 900).toInt();
  for (var i = 0; i < count; i++) {
    canvas.drawCircle(
      Offset(noise.nextDouble() * size.width, noise.nextDouble() * size.height),
      0.7,
      dot,
    );
  }
}
