import 'package:flutter/material.dart';

const Color auraClear = Color(0x00000000);

enum AuraTint { primary, fixed }

const List<double> auraStops = [0, .5, 1];
const List<double> auraFalloff = [1, .55, 0];

class AuraLayer {
  const AuraLayer(
    this.alignment,
    this.radius,
    this.opacity,
    this.blend, {
    this.sigma = 28,
    this.tint = AuraTint.fixed,
    this.rgb = 0,
  });
  final Alignment alignment;
  final double radius, opacity, sigma;
  final BlendMode blend;
  final AuraTint tint;
  final int rgb;

  Color color(ColorScheme scheme) => switch (tint) {
    AuraTint.primary => scheme.primary,
    AuraTint.fixed => Color(0xff000000 | rgb),
  };

  double alphaAt(double distance) {
    if (distance >= 1) return 0;
    final scaled = distance * (auraStops.length - 1);
    final index = scaled.floor();
    final local = scaled - index;
    return opacity *
        (auraFalloff[index] +
            (auraFalloff[index + 1] - auraFalloff[index]) * local);
  }
}

class AuraPreset {
  const AuraPreset({
    required this.light,
    required this.dark,
    this.grain = 0,
    this.drift = 0,
  });
  final List<AuraLayer> light, dark;
  final double grain, drift;

  List<AuraLayer> layers(bool isDark) => isDark ? dark : light;

  factory AuraPreset.duo(int first, int second, {double grain = 0}) =>
      AuraPreset(
        light: [
          AuraLayer(
            const Alignment(-.9, -.9),
            .9,
            .2,
            BlendMode.srcOver,
            rgb: first,
          ),
          AuraLayer(
            const Alignment(1, .8),
            .8,
            .16,
            BlendMode.softLight,
            rgb: second,
          ),
          AuraLayer(
            const Alignment(.1, -.2),
            .55,
            .08,
            BlendMode.srcOver,
            rgb: first,
          ),
        ],
        dark: [
          AuraLayer(
            const Alignment(-.9, -.9),
            .9,
            .24,
            BlendMode.screen,
            rgb: first,
          ),
          AuraLayer(
            const Alignment(1, .8),
            .8,
            .2,
            BlendMode.plus,
            rgb: second,
          ),
          AuraLayer(
            const Alignment(.1, -.2),
            .55,
            .1,
            BlendMode.screen,
            rgb: first,
          ),
        ],
        grain: grain,
        drift: .6,
      );
}
