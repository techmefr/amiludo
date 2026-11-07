import 'dart:math';

import 'package:flutter/painting.dart';

Path roundedPolygon(List<Offset> points, double radius) {
  final path = Path();
  final n = points.length;
  for (var i = 0; i < n; i++) {
    final prev = points[(i + n - 1) % n];
    final cur = points[i];
    final next = points[(i + 1) % n];
    final toPrev = prev - cur;
    final toNext = next - cur;
    final r = min(radius, min(toPrev.distance, toNext.distance) * 0.35);
    final a = cur + toPrev / toPrev.distance * r;
    final b = cur + toNext / toNext.distance * r;
    if (i == 0) {
      path.moveTo(a.dx, a.dy);
    } else {
      path.lineTo(a.dx, a.dy);
    }
    path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
  }
  return path..close();
}

Color tintFacet(Color base, int index) {
  final hsl = HSLColor.fromColor(base);
  final lift = ((index * 37) % 7 - 3) * 0.015;
  final hue = ((index % 5) - 2) * 3.0;
  return hsl
      .withHue((hsl.hue + hue) % 360)
      .withLightness((hsl.lightness + lift).clamp(0.05, 0.95))
      .toColor();
}

Color lighten(Color c, double t) => Color.lerp(c, const Color(0xFFFFFFFF), t)!;

Color darken(Color c, double t) => Color.lerp(c, const Color(0xFF000000), t)!;
