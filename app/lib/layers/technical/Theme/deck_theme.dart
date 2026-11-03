import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';

class DeckPalette {
  const DeckPalette(
    this.name,
    this.ink,
    this.accent,
    this.hero,
    this.background,
    this.darkInk,
    this.darkAccent,
    this.darkHero,
    this.darkBackground,
    this.signal,
  );
  final String name;
  final int ink,
      accent,
      hero,
      background,
      darkInk,
      darkAccent,
      darkHero,
      darkBackground,
      signal;
  static const values = {
    'play': DeckPalette(
      'Confettis',
      0xff292441,
      0xff7150CC,
      0xffEEE6FA,
      0xffFFF9F0,
      0xffF6F0FF,
      0xffC7AEFF,
      0xff302849,
      0xff1C192B,
      0xffFF956D,
    ),
    'acid': DeckPalette(
      'Acid Circuit',
      0xff17211d,
      0xffbadb16,
      0xffe2ead0,
      0xffeef0df,
      0xffedf3da,
      0xffd5ff45,
      0xff18261f,
      0xff0b100f,
      0xffff774d,
    ),
    'neon': DeckPalette(
      'Night City',
      0xff182649,
      0xff35c4da,
      0xffdde8f4,
      0xffeff1fa,
      0xffe0edff,
      0xff59e5ff,
      0xff142135,
      0xff0a0f1b,
      0xfff873d2,
    ),
    'amber': DeckPalette(
      'Amber Terminal',
      0xff392a1c,
      0xffd39b2d,
      0xffe9debf,
      0xfff0e9d8,
      0xfffff0d1,
      0xffffc36b,
      0xff30251b,
      0xff15100c,
      0xffc4efaa,
    ),
    'plasma': DeckPalette(
      'Plasma',
      0xff3a2054,
      0xffca7bdc,
      0xffebddf0,
      0xfff4edf6,
      0xfff4e7ff,
      0xffdd9dff,
      0xff291a38,
      0xff100b18,
      0xffa9ffbd,
    ),
    'lichen': DeckPalette(
      'Lichen',
      0xff253d36,
      0xffd6eb96,
      0xffe8eddf,
      0xfff5f3ed,
      0xffdce8d9,
      0xffa6ca67,
      0xff293c32,
      0xff19271f,
      0xffd6eb96,
    ),
    'lavender': DeckPalette(
      'Lavande',
      0xff493d62,
      0xffd9c7f2,
      0xffeee7f4,
      0xfff6f2f8,
      0xffe8def5,
      0xffbd95ec,
      0xff3b304d,
      0xff241e30,
      0xffdfacd4,
    ),
    'clay': DeckPalette(
      'Terre cuite',
      0xff603e33,
      0xffedb69a,
      0xfff3e2d6,
      0xfff8f2ec,
      0xfff0ded1,
      0xffefb393,
      0xff493227,
      0xff2d221c,
      0xfff4d197,
    ),
    'ocean': DeckPalette(
      'Marée',
      0xff294a59,
      0xffa7dbe2,
      0xffdcecef,
      0xfff0f5f5,
      0xffd6e9ed,
      0xff84d3dd,
      0xff243c47,
      0xff17292f,
      0xffe5b4df,
    ),
    'honey': DeckPalette(
      'Miel',
      0xff55472d,
      0xffefd17f,
      0xfff0e7cc,
      0xfff9f5e9,
      0xffeee5cb,
      0xffefd17f,
      0xff433b27,
      0xff2b271b,
      0xfff1ae78,
    ),
    'rose': DeckPalette(
      'Rosée',
      0xff5d3b4c,
      0xffedbbd0,
      0xfff1e0e8,
      0xfff8f1f4,
      0xffefdee7,
      0xffedbbd0,
      0xff46303d,
      0xff2d2028,
      0xffc6a4eb,
    ),
  };
}

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

const _symbolFallback = ['NotoSansSymbols2', 'NotoSansSymbols'];

ThemeData deckTheme(Appearance appearance, Brightness brightness) {
  final dark = brightness == Brightness.dark,
      p = DeckPalette.values[appearance.palette]!;
  final ink = Color(dark ? p.darkInk : p.ink),
      accent = Color(dark ? p.darkAccent : p.accent),
      background = Color(dark ? p.darkBackground : p.background),
      hero = Color(dark ? p.darkHero : p.hero),
      surface = Color.lerp(background, ink, .035)!;
  final border = Color.lerp(background, ink, .22)!;
  final heading = appearance.skin == 'cyber'
      ? 'ChakraPetch'
      : appearance.skin == 'orbital'
      ? 'Rajdhani'
      : 'BricolageGrotesque';
  final style = DeckStyle(
    shape: appearance.shape,
    signal: dark ? Color(p.signal) : ink,
    headingFont: heading,
    compact: appearance.compact,
  );
  final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness)
      .copyWith(
        primary: accent,
        onPrimary: appearance.palette == 'play' && !dark
            ? Colors.white
            : Color(p.darkBackground),
        secondary: hero,
        onSecondary: ink,
        surface: surface,
        onSurface: ink,
        outline: border,
        surfaceContainerHighest: hero,
      );
  final base = _deckBase(appearance, brightness, scheme, background);
  final scale = appearance.large ? 1.15 : 1.0;
  final themed = appearance.skin == 'cyber' || appearance.skin == 'orbital';
  final buttonText = TextStyle(
    fontFamily: themed ? heading : appearance.font,
    fontFamilyFallback: _symbolFallback,
    fontSize: 15 * scale,
    fontWeight: FontWeight.w700,
    letterSpacing: themed ? 1 : 0,
  );
  final text = base.textTheme.apply(bodyColor: ink, displayColor: ink);
  return base.copyWith(
    extensions: [style],
    textTheme: _deckTextTheme(text, heading, scale, themed),
    dividerColor: border,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      centerTitle: false,
    ),
    filledButtonTheme: _filledButtonTheme(style, buttonText),
    outlinedButtonTheme: _outlinedButtonTheme(style, buttonText, ink, border),
    textButtonTheme: _textButtonTheme(dark ? accent : ink, buttonText),
    inputDecorationTheme: _inputTheme(appearance, surface, border),
    navigationBarTheme: _navigationBarTheme(appearance, background, hero),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: style.border(border),
    ),
    snackBarTheme: _snackBarTheme(appearance, ink, background),
    chipTheme: _chipTheme(base.chipTheme, appearance, border),
    cardTheme: CardThemeData(
      color: surface,
      shape: style.border(border),
      elevation: 0,
    ),
  );
}

ThemeData _deckBase(
  Appearance appearance,
  Brightness brightness,
  ColorScheme scheme,
  Color background,
) => ThemeData(
  useMaterial3: true,
  brightness: brightness,
  colorScheme: scheme,
  scaffoldBackgroundColor: background,
  fontFamily: appearance.font,
  fontFamilyFallback: _symbolFallback,
  visualDensity: appearance.compact
      ? VisualDensity.compact
      : VisualDensity.standard,
);

TextButtonThemeData _textButtonTheme(Color foreground, TextStyle text) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: foreground,
        textStyle: text,
      ),
    );

ChipThemeData _chipTheme(
  ChipThemeData chip,
  Appearance appearance,
  Color border,
) => chip.copyWith(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(appearance.skin == 'play' ? 16 : 4),
  ),
  side: BorderSide(color: border),
);

SnackBarThemeData _snackBarTheme(
  Appearance appearance,
  Color ink,
  Color background,
) => SnackBarThemeData(
  backgroundColor: ink,
  contentTextStyle: TextStyle(
    color: background,
    fontFamily: appearance.font,
    fontFamilyFallback: _symbolFallback,
  ),
);

TextTheme _deckTextTheme(
  TextTheme text,
  String heading,
  double scale,
  bool themed,
) => _bodyTextTheme(_headingTextTheme(text, heading, scale, themed), scale);

TextTheme _headingTextTheme(
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

TextTheme _bodyTextTheme(TextTheme text, double scale) {
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

FilledButtonThemeData _filledButtonTheme(DeckStyle style, TextStyle text) =>
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: style.border(Colors.transparent),
        textStyle: text,
      ),
    );

OutlinedButtonThemeData _outlinedButtonTheme(
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

InputDecorationTheme _inputTheme(
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

NavigationBarThemeData _navigationBarTheme(
  Appearance appearance,
  Color background,
  Color hero,
) => NavigationBarThemeData(
  backgroundColor: background,
  indicatorColor: hero,
  labelTextStyle: WidgetStatePropertyAll(
    TextStyle(
      fontFamily: appearance.font,
      fontFamilyFallback: _symbolFallback,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),
);
