import 'package:flutter/material.dart';

class DeckStyle extends ThemeExtension<DeckStyle> {
  const DeckStyle({
    required this.shape,
    required this.signal,
    required this.headingFont,
    required this.compact,
  });
  final String shape, headingFont;
  final Color signal;
  final bool compact;
  OutlinedBorder border(Color color) => shape == 'cut'
      ? BeveledRectangleBorder(
          side: BorderSide(color: color),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        )
      : RoundedRectangleBorder(
          side: BorderSide(color: color),
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
  }) => DeckStyle(
    shape: shape ?? this.shape,
    signal: signal ?? this.signal,
    headingFont: headingFont ?? this.headingFont,
    compact: compact ?? this.compact,
  );
  @override
  DeckStyle lerp(covariant DeckStyle? other, double t) =>
      t < .5 ? this : other ?? this;
}
