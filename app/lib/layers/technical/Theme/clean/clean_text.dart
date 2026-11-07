import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

TextTheme cleanTextTheme(
  TextTheme base,
  Color ink,
  Color secondary,
  double scale,
) {
  TextStyle style(
    TextStyle? from,
    double size,
    FontWeight weight, {
    double height = 1.3,
    double letterSpacing = 0,
    Color? color,
    bool tabular = true,
  }) => (from ?? const TextStyle()).copyWith(
    fontSize: size * scale,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
    color: color ?? ink,
    fontFeatures: tabular ? Numerals.tabular : null,
  );
  return base.copyWith(
    displayLarge: style(base.displayLarge, 48, FontWeight.w700, height: 1.1),
    displayMedium: style(base.displayMedium, 40, FontWeight.w700, height: 1.1),
    displaySmall: style(
      base.displaySmall,
      34,
      FontWeight.w700,
      height: 1.12,
      letterSpacing: .37,
    ),
    headlineLarge: style(
      base.headlineLarge,
      34,
      FontWeight.w700,
      height: 1.15,
      letterSpacing: .37,
    ),
    headlineMedium: style(
      base.headlineMedium,
      28,
      FontWeight.w700,
      height: 1.18,
      letterSpacing: .36,
    ),
    headlineSmall: style(
      base.headlineSmall,
      22,
      FontWeight.w700,
      height: 1.25,
      letterSpacing: .35,
    ),
    titleLarge: style(base.titleLarge, 20, FontWeight.w600, height: 1.3),
    titleMedium: style(
      base.titleMedium,
      17,
      FontWeight.w600,
      height: 1.35,
      letterSpacing: -.4,
    ),
    titleSmall: style(base.titleSmall, 15, FontWeight.w600, height: 1.35),
    bodyLarge: style(
      base.bodyLarge,
      17,
      FontWeight.w400,
      height: 1.45,
      letterSpacing: -.4,
      tabular: false,
    ),
    bodyMedium: style(
      base.bodyMedium,
      15,
      FontWeight.w400,
      height: 1.5,
      letterSpacing: -.2,
      tabular: false,
    ),
    bodySmall: style(
      base.bodySmall,
      13,
      FontWeight.w400,
      height: 1.45,
      color: secondary,
      tabular: false,
    ),
    labelLarge: style(base.labelLarge, 17, FontWeight.w600, height: 1.2),
    labelMedium: style(
      base.labelMedium,
      13,
      FontWeight.w500,
      height: 1.3,
      color: secondary,
    ),
    labelSmall: style(
      base.labelSmall,
      12,
      FontWeight.w500,
      height: 1.3,
      color: secondary,
    ),
  );
}
