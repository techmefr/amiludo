import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_layer.dart';

double auraRatio(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (math.max(x, y) + .05) / (math.min(x, y) + .05);
}

Color _screen(Color base, Color tint, double alpha) {
  double mix(double b, double t) => 1 - (1 - b) * (1 - t * alpha);
  return Color.from(
    alpha: 1,
    red: mix(base.r, tint.r),
    green: mix(base.g, tint.g),
    blue: mix(base.b, tint.b),
  );
}

Color _plus(Color base, Color tint, double alpha) => Color.from(
  alpha: 1,
  red: math.min(1, base.r + tint.r * alpha),
  green: math.min(1, base.g + tint.g * alpha),
  blue: math.min(1, base.b + tint.b * alpha),
);

Color _worst(Color base, Color tint, double alpha, BlendMode blend, Color ink) {
  final over = Color.alphaBlend(tint.withValues(alpha: alpha), base);
  return switch (blend) {
    BlendMode.srcOver => over,
    BlendMode.plus => _plus(base, tint, alpha),
    _ =>
      auraRatio(over, ink) < auraRatio(_screen(base, tint, alpha), ink)
          ? over
          : _screen(base, tint, alpha),
  };
}

Color auraColorAt({
  required AuraPreset preset,
  required bool dark,
  required ColorScheme scheme,
  required Color base,
  required Color ink,
  required Offset unit,
  required Size size,
}) {
  var color = base;
  for (final layer in preset.layers(dark)) {
    final centre = layer.alignment.alongSize(size);
    final point = Offset(
      (unit.dx + 1) / 2 * size.width,
      (unit.dy + 1) / 2 * size.height,
    );
    final distance =
        (point - centre).distance / (layer.radius * size.longestSide);
    final alpha = layer.alphaAt(distance);
    if (alpha <= 0) continue;
    color = _worst(color, layer.color(scheme), alpha, layer.blend, ink);
  }
  return color;
}

double auraWorstRatio({
  required AuraPreset preset,
  required bool dark,
  required ColorScheme scheme,
  required Color base,
  required Color ink,
  Size size = const Size(400, 800),
}) {
  var worst = double.infinity;
  for (var x = -1.0; x <= 1; x += .25) {
    for (var y = -1.0; y <= 1; y += .25) {
      final at = auraColorAt(
        preset: preset,
        dark: dark,
        scheme: scheme,
        base: base,
        ink: ink,
        unit: Offset(x, y),
        size: size,
      );
      for (final noise in [const Color(0xffffffff), const Color(0xff000000)]) {
        final grained = Color.alphaBlend(
          noise.withValues(alpha: preset.grain),
          at,
        );
        worst = math.min(worst, auraRatio(grained, ink));
      }
    }
  }
  return worst;
}
