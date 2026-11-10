import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

ColorScheme withSurfaceTokens(
  ColorScheme scheme, {
  required Color background,
  required Color ink,
  required Color hero,
}) {
  Color lift(double amount) => Color.lerp(background, ink, amount)!;
  final grounds = [
    background,
    scheme.surface,
    lift(.02),
    lift(.04),
    lift(.06),
    lift(.08),
    hero,
  ];
  final variant = grounds.fold(
    Color.lerp(ink, background, .28)!,
    (kept, ground) => ensureContrast(kept, ground, minimum: aaText + 2.5),
  );
  return scheme.copyWith(
    surfaceContainerLowest: background,
    surfaceContainerLow: lift(.02),
    surfaceContainer: lift(.04),
    surfaceContainerHigh: lift(.06),
    surfaceDim: lift(.08),
    surfaceBright: background,
    onSurfaceVariant: variant,
    inverseSurface: ink,
    onInverseSurface: onColorFor(ink),
    onPrimaryContainer: onColorFor(scheme.primaryContainer),
    onSecondaryContainer: onColorFor(scheme.secondaryContainer),
    onTertiary: onColorFor(scheme.tertiary),
    onTertiaryContainer: onColorFor(scheme.tertiaryContainer),
    onError: onColorFor(scheme.error),
    onErrorContainer: onColorFor(scheme.errorContainer),
  );
}
