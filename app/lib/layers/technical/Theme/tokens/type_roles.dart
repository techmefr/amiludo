import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

abstract final class TypeRoles {
  static TextStyle display(BuildContext context) => _style(
    Theme.of(context).textTheme.displaySmall,
    TypeScale.display,
    FontWeight.w700,
    1.15,
  );

  static TextStyle title(BuildContext context) => _style(
    Theme.of(context).textTheme.headlineLarge,
    TypeScale.headline,
    FontWeight.w700,
    1.2,
  );

  static TextStyle sectionTitle(BuildContext context) => _style(
    Theme.of(context).textTheme.titleLarge,
    TypeScale.title,
    FontWeight.w600,
    1.25,
  );

  static TextStyle body(BuildContext context) => _style(
    Theme.of(context).textTheme.bodyLarge,
    TypeScale.body,
    FontWeight.w400,
    1.4,
  );

  static TextStyle caption(BuildContext context) => _style(
    Theme.of(context).textTheme.bodySmall,
    TypeScale.caption,
    FontWeight.w400,
    1.35,
    muted: true,
    scheme: Theme.of(context).colorScheme,
  );

  static TextStyle kicker(BuildContext context) => _style(
    Theme.of(context).textTheme.labelMedium,
    TypeScale.caption,
    FontWeight.w700,
    1.3,
    spacing: 1.2,
  );

  static TextStyle _style(
    TextStyle? base,
    double size,
    FontWeight weight,
    double height, {
    double? spacing,
    bool muted = false,
    ColorScheme? scheme,
  }) => (base ?? const TextStyle()).copyWith(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
    color: muted ? scheme?.onSurfaceVariant : null,
  );
}
