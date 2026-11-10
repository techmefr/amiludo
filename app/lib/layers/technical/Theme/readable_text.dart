import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

TextTheme readableTextTheme(TextTheme text, Color background) {
  TextStyle? fix(TextStyle? style) {
    final color = style?.color;
    if (style == null || color == null) return style;
    return style.copyWith(color: ensureContrast(color, background, minimum: aaText + .6));
  }

  return text.copyWith(
    displayLarge: fix(text.displayLarge),
    displayMedium: fix(text.displayMedium),
    displaySmall: fix(text.displaySmall),
    headlineLarge: fix(text.headlineLarge),
    headlineMedium: fix(text.headlineMedium),
    headlineSmall: fix(text.headlineSmall),
    titleLarge: fix(text.titleLarge),
    titleMedium: fix(text.titleMedium),
    titleSmall: fix(text.titleSmall),
    bodyLarge: fix(text.bodyLarge),
    bodyMedium: fix(text.bodyMedium),
    bodySmall: fix(text.bodySmall),
    labelLarge: fix(text.labelLarge),
    labelMedium: fix(text.labelMedium),
    labelSmall: fix(text.labelSmall),
  );
}

ColorScheme readableScheme(ColorScheme scheme, Color background) =>
    scheme.copyWith(
      onSurface: ensureContrast(scheme.onSurface, background, minimum: aaText + .6),
      onSurfaceVariant: ensureContrast(
        scheme.onSurfaceVariant,
        background,
        minimum: aaText + 2.2,
      ),
      error: ensureContrast(scheme.error, background),
    );
