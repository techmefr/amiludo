import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';

const deckSymbolFallback = ['NotoSansSymbols2', 'NotoSansSymbols'];

TextButtonThemeData deckTextButtonTheme(Color foreground, TextStyle text) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: foreground,
        textStyle: text,
      ),
    );

ChipThemeData deckChipTheme(
  ChipThemeData chip,
  Appearance appearance,
  Color border,
) => chip.copyWith(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(appearance.skin == 'play' ? 16 : 4),
  ),
  side: BorderSide(color: border),
);

SnackBarThemeData deckSnackBarTheme(
  Appearance appearance,
  Color ink,
  Color background,
) => SnackBarThemeData(
  backgroundColor: ink,
  contentTextStyle: TextStyle(
    color: background,
    fontFamily: appearance.font,
    fontFamilyFallback: deckSymbolFallback,
  ),
);

TextTheme deckDeckTextTheme(
  TextTheme text,
  String heading,
  double scale,
  bool themed,
) => deckBodyTextTheme(
  deckHeadingTextTheme(text, heading, scale, themed),
  scale,
);

TextTheme deckHeadingTextTheme(
  TextTheme text,
  String heading,
  double scale,
  bool themed,
) {
  TextStyle? headingStyle(
    TextStyle? style,
    double size,
    FontWeight weight, {
    double height = 1.2,
    double letterSpacing = 0,
  }) => style?.copyWith(
    fontFamily: heading,
    fontSize: size * scale,
    fontWeight: weight,
    height: height,
    letterSpacing: themed ? 0 : letterSpacing,
  );
  return text.copyWith(
    displaySmall: headingStyle(
      text.displaySmall,
      44,
      FontWeight.w800,
      height: 1.05,
      letterSpacing: -1,
    ),
    headlineLarge: headingStyle(
      text.headlineLarge,
      36,
      FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.6,
    ),
    headlineMedium: headingStyle(
      text.headlineMedium,
      28,
      FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.4,
    ),
    headlineSmall: headingStyle(
      text.headlineSmall,
      22,
      FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleLarge: headingStyle(text.titleLarge, 20, FontWeight.w600),
    titleMedium: headingStyle(text.titleMedium, 17, FontWeight.w600),
  );
}

TextTheme deckBodyTextTheme(TextTheme text, double scale) {
  TextStyle? bodyStyle(
    TextStyle? style,
    double size,
    FontWeight weight, {
    double height = 1.5,
    double letterSpacing = 0,
  }) => style?.copyWith(
    fontSize: size * scale,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
  );
  return text.copyWith(
    titleSmall: bodyStyle(text.titleSmall, 15, FontWeight.w700),
    bodyLarge: bodyStyle(text.bodyLarge, 17, FontWeight.w400),
    bodyMedium: bodyStyle(text.bodyMedium, 15, FontWeight.w400),
    bodySmall: bodyStyle(text.bodySmall, 13, FontWeight.w400, height: 1.4),
    labelLarge: bodyStyle(text.labelLarge, 15, FontWeight.w700, height: 1.2),
    labelMedium: bodyStyle(text.labelMedium, 13, FontWeight.w500, height: 1.3),
    labelSmall: bodyStyle(
      text.labelSmall,
      12,
      FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.3,
    ),
  );
}

FilledButtonThemeData deckFilledButtonTheme(DeckStyle style, TextStyle text) =>
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: style.border(Colors.transparent),
        textStyle: text,
      ),
    );

OutlinedButtonThemeData deckOutlinedButtonTheme(
  DeckStyle style,
  TextStyle text,
  Color ink,
  Color border,
) => OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(48, 48),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    foregroundColor: ink,
    side: BorderSide(color: border),
    shape: style.border(border),
    textStyle: text,
  ),
);

InputDecorationTheme deckInputTheme(
  Appearance appearance,
  Color surface,
  Color border,
) {
  OutlineInputBorder outline() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      ['soft', 'round'].contains(appearance.shape) ? 16 : 4,
    ),
    borderSide: BorderSide(color: border),
  );
  return InputDecorationTheme(
    filled: true,
    fillColor: surface,
    border: outline(),
    enabledBorder: outline(),
  );
}

NavigationBarThemeData deckNavigationBarTheme(
  Appearance appearance,
  Color background,
  Color hero,
) => NavigationBarThemeData(
  backgroundColor: background,
  indicatorColor: hero,
  labelTextStyle: WidgetStatePropertyAll(
    TextStyle(
      fontFamily: appearance.font,
      fontFamilyFallback: deckSymbolFallback,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),
);
