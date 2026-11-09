import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

String? deckFontFamily(String font) => font == 'System' ? null : font;

class DeckStyle extends ThemeExtension<DeckStyle> {
  const DeckStyle({
    required this.shape,
    required this.signal,
    required this.headingFont,
    required this.compact,
    this.borderWidth = 1,
    this.glow,
    this.clean = false,
    this.skin = 'clean',
  });
  final String shape, headingFont;
  final Color signal;
  final bool compact;
  final double borderWidth;
  final Color? glow;
  final bool clean;
  final String skin;
  OutlinedBorder border(Color color, {bool strong = false}) => clean
      ? RoundedRectangleBorder(
          side: strong ? BorderSide(color: color, width: 2) : BorderSide.none,
          borderRadius: BorderRadius.circular(Radii.group),
        )
      : shape == 'cut'
      ? BeveledRectangleBorder(
          side: BorderSide(color: color, width: borderWidth),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        )
      : RoundedRectangleBorder(
          side: BorderSide(color: color, width: borderWidth),
          borderRadius: BorderRadius.circular(
            shape == 'round'
                ? 28
                : shape == 'soft'
                ? 20
                : 4,
          ),
        );
  @override
  DeckStyle copyWith({
    String? shape,
    Color? signal,
    String? headingFont,
    bool? compact,
    double? borderWidth,
    Color? glow,
    bool? clean,
    String? skin,
  }) => DeckStyle(
    shape: shape ?? this.shape,
    signal: signal ?? this.signal,
    headingFont: headingFont ?? this.headingFont,
    compact: compact ?? this.compact,
    borderWidth: borderWidth ?? this.borderWidth,
    glow: glow ?? this.glow,
    clean: clean ?? this.clean,
    skin: skin ?? this.skin,
  );
  @override
  DeckStyle lerp(covariant DeckStyle? other, double t) =>
      t < .5 ? this : other ?? this;
}
