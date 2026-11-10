import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class Pair {
  const Pair(this.name, this.foreground, this.background, [this.minimum = 4.5]);
  final String name;
  final Color? foreground, background;
  final double minimum;

  double get ratio => contrastOf(foreground!, background!);
  bool get usable => foreground != null && background != null;
  bool get passes => !usable || ratio >= minimum;
  @override
  String toString() =>
      '$name ${usable ? ratio.toStringAsFixed(2) : 'n/a'} < $minimum';
}

Color opaque(Color? color, Color page) =>
    color == null || color.a == 0 ? page : color;

Color? resolved(WidgetStateProperty<Color?>? property, [Set<WidgetState>? s]) =>
    property?.resolve(s ?? <WidgetState>{});

Pair _text(String name, TextStyle? style, Color? background) =>
    Pair(name, style?.color, background);

List<Pair> schemePairs(ThemeData theme) {
  final s = theme.colorScheme;
  final page = theme.scaffoldBackgroundColor;
  return [
    Pair('primary button', s.onPrimary, s.primary),
    Pair('secondary', s.onSecondary, s.secondary),
    Pair('secondary container', s.onSecondaryContainer, s.secondaryContainer),
    Pair('primary container', s.onPrimaryContainer, s.primaryContainer),
    Pair('tertiary container', s.onTertiaryContainer, s.tertiaryContainer),
    Pair('error', s.onError, s.error),
    Pair('error container', s.onErrorContainer, s.errorContainer),
    Pair('surface', s.onSurface, s.surface),
    Pair('surface on page', s.onSurface, page),
    Pair('variant on surface', s.onSurfaceVariant, s.surface),
    Pair('variant on page', s.onSurfaceVariant, page),
    Pair('on highest', s.onSurface, s.surfaceContainerHighest),
    Pair('variant on highest', s.onSurfaceVariant, s.surfaceContainerHighest),
    Pair('inverse', s.onInverseSurface, s.inverseSurface),
    Pair('accent ink on page', s.accentInk, page, 3),
    Pair('accent ink on surface', s.accentInk, s.surface, 3),
    Pair('error text on page', s.error, page),
    for (final (name, ground) in [
      ('lowest', s.surfaceContainerLowest),
      ('low', s.surfaceContainerLow),
      ('container', s.surfaceContainer),
      ('high', s.surfaceContainerHigh),
      ('dim', s.surfaceDim),
      ('bright', s.surfaceBright),
    ]) ...[
      Pair('onSurface on $name', s.onSurface, ground),
      Pair('variant on $name', s.onSurfaceVariant, ground),
    ],
    Pair(
      'banner text',
      theme.bannerTheme.contentTextStyle?.color ?? s.onSurface,
      theme.bannerTheme.backgroundColor,
    ),
    Pair(
      'banner action',
      resolved(theme.textButtonTheme.style?.foregroundColor) ?? s.primary,
      theme.bannerTheme.backgroundColor,
    ),
  ];
}

List<Pair> textPairs(ThemeData theme) {
  final t = theme.textTheme;
  final page = theme.scaffoldBackgroundColor,
      surface = theme.colorScheme.surface;
  final styles = {
    'displaySmall': t.displaySmall,
    'headlineMedium': t.headlineMedium,
    'headlineSmall': t.headlineSmall,
    'titleLarge': t.titleLarge,
    'titleMedium': t.titleMedium,
    'titleSmall': t.titleSmall,
    'bodyLarge': t.bodyLarge,
    'bodyMedium': t.bodyMedium,
    'bodySmall': t.bodySmall,
    'labelLarge': t.labelLarge,
    'labelMedium': t.labelMedium,
    'labelSmall': t.labelSmall,
  };
  return [
    for (final e in styles.entries) ...[
      _text('${e.key} on page', e.value, page),
      _text('${e.key} on surface', e.value, surface),
    ],
  ];
}

List<Pair> componentPairs(ThemeData theme) {
  final s = theme.colorScheme;
  final page = theme.scaffoldBackgroundColor;
  final filled = theme.filledButtonTheme.style;
  final outlined = theme.outlinedButtonTheme.style;
  final plain = theme.textButtonTheme.style;
  final chip = theme.chipTheme;
  final seg = theme.segmentedButtonTheme.style;
  final nav = theme.navigationBarTheme;
  final input = theme.inputDecorationTheme;
  final selected = <WidgetState>{WidgetState.selected};
  return [
    Pair(
      'filled button',
      resolved(filled?.foregroundColor) ?? s.onPrimary,
      resolved(filled?.backgroundColor) ?? s.primary,
    ),
    Pair(
      'outlined button',
      resolved(outlined?.foregroundColor) ?? s.primary,
      resolved(outlined?.backgroundColor) ?? page,
    ),
    Pair(
      'text button',
      resolved(plain?.foregroundColor) ?? s.primary,
      resolved(plain?.backgroundColor) ?? page,
    ),
    Pair(
      'chip label',
      chip.labelStyle?.color ?? s.onSurfaceVariant,
      chip.backgroundColor ?? page,
    ),
    Pair(
      'selected chip label',
      chip.secondaryLabelStyle?.color ?? s.onSecondaryContainer,
      chip.selectedColor ?? s.secondaryContainer,
    ),
    Pair(
      'segmented',
      resolved(seg?.foregroundColor) ?? s.onSurface,
      resolved(seg?.backgroundColor) ?? page,
    ),
    Pair(
      'selected segmented',
      resolved(seg?.foregroundColor, selected) ?? s.onSecondaryContainer,
      resolved(seg?.backgroundColor, selected) ?? s.secondaryContainer,
    ),
    Pair(
      'nav label',
      nav.labelTextStyle?.resolve({})?.color ?? s.onSurfaceVariant,
      opaque(nav.backgroundColor, page),
    ),
    Pair(
      'nav selected label',
      nav.labelTextStyle?.resolve(selected)?.color ?? s.onSurface,
      opaque(nav.backgroundColor, page),
    ),
    Pair(
      'snackbar',
      theme.snackBarTheme.contentTextStyle?.color ?? s.onInverseSurface,
      theme.snackBarTheme.backgroundColor ?? s.inverseSurface,
    ),
    Pair(
      'input text',
      theme.textTheme.bodyLarge?.color,
      input.fillColor ?? s.surface,
    ),
    Pair('input hint', s.onSurfaceVariant, input.fillColor ?? s.surface),
    Pair(
      'appbar title',
      theme.appBarTheme.foregroundColor ?? s.onSurface,
      theme.appBarTheme.backgroundColor ?? page,
    ),
    Pair('divider', theme.dividerColor, page, 1),
  ];
}

List<Pair> boundaryPairs(ThemeData theme) {
  final input = theme.inputDecorationTheme;
  final border = input.enabledBorder;
  final edge = border is OutlineInputBorder && border.borderSide.width > 0
      ? border.borderSide.color
      : null;
  return [
    Pair('input border', edge, input.fillColor ?? theme.colorScheme.surface, 3),
  ];
}
