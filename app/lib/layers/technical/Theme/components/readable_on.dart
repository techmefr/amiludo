import 'package:flutter/material.dart';

const _lightInk = Color(0xFFFFFFFF);
const _darkInk = Color(0xFF151515);

const double aaText = 4.5;
const double aaLarge = 3;

double contrastOf(Color foreground, Color background) {
  final base = Color.alphaBlend(background, const Color(0xFF000000));
  final top = Color.alphaBlend(foreground, base);
  final x = top.computeLuminance(), y = base.computeLuminance();
  return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
}

Color onColorFor(
  Color background, {
  Color light = _lightInk,
  Color dark = _darkInk,
  double minimum = aaText,
}) {
  final withLight = contrastOf(light, background);
  final withDark = contrastOf(dark, background);
  if (withLight >= minimum && withDark >= minimum) {
    return withDark >= withLight ? dark : light;
  }
  return withLight >= withDark ? light : dark;
}

Color readableOn(Color background) => onColorFor(background);

Color ensureContrast(
  Color foreground,
  Color background, {
  double minimum = aaText,
}) {
  if (contrastOf(foreground, background) >= minimum) return foreground;
  final target = onColorFor(background);
  for (var step = 1; step <= 20; step++) {
    final color = Color.lerp(foreground, target, step / 20)!;
    if (contrastOf(color, background) >= minimum) return color;
  }
  return target;
}

Color gradientEnd(Color from, Color to, Color ink) {
  for (var step = 10; step >= 0; step--) {
    final color = Color.lerp(from, to, step / 10)!;
    if (contrastOf(ink, color) >= aaText) return color;
  }
  return from;
}

extension AccentInk on ColorScheme {
  Color get accentInk =>
      ensureContrast(primary, surface, minimum: aaLarge + .2);

  Color get accentText =>
      ensureContrast(primary, surface, minimum: aaText + .3);
}
