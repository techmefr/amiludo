import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_layer.dart';

class AuraPainter extends CustomPainter {
  const AuraPainter({
    required this.layers,
    required this.scheme,
    required this.base,
  });
  final List<AuraLayer> layers;
  final ColorScheme scheme;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    canvas.drawRect(bounds, Paint()..color = base);
    for (final layer in layers) {
      final centre = layer.alignment.alongSize(size);
      final radius = layer.radius * size.longestSide;
      final color = layer.color(scheme);
      final paint = Paint()
        ..blendMode = layer.blend
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, layer.sigma)
        ..shader = ui.Gradient.radial(
          centre,
          radius,
          [
            for (final f in auraFalloff)
              color.withValues(alpha: layer.opacity * f),
          ],
          [for (final s in auraStops) s],
        );
      canvas.drawCircle(centre, radius, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(AuraPainter old) =>
      old.base != base || old.scheme != scheme || old.layers != layers;
}

class AuraGrainPainter extends CustomPainter {
  const AuraGrainPainter(this.strength);
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final count = (size.width * size.height * .04).floor().clamp(0, 60000);
    final light = Float32List(count * 2), dark = Float32List(count * 2);
    for (var i = 0; i < count * 2; i++) {
      light[i] = random.nextDouble() * (i.isEven ? size.width : size.height);
      dark[i] = random.nextDouble() * (i.isEven ? size.width : size.height);
    }
    for (final (points, color) in [
      (light, const Color(0xffffffff)),
      (dark, const Color(0xff000000)),
    ]) {
      canvas.drawRawPoints(
        ui.PointMode.points,
        points,
        Paint()
          ..color = color.withValues(alpha: strength)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(AuraGrainPainter old) => old.strength != strength;
}
