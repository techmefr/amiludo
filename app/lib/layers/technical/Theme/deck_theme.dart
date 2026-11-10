import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/clean/clean_theme.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/deck_component_themes.dart';
import 'package:amiludo/layers/technical/Theme/deck_palette.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';
import 'package:amiludo/layers/technical/Theme/surface_tokens.dart';

export 'package:amiludo/layers/technical/Theme/deck_palette.dart';
export 'package:amiludo/layers/technical/Theme/deck_style.dart';

const deckSymbolFallback = ['NotoSansSymbols2', 'NotoSansSymbols'];

ThemeData deckTheme(Appearance appearance, Brightness brightness) {
  if (appearance.skin == 'clean') return cleanTheme(appearance, brightness);
  final game = appearance.skin == 'game',
      dark = game || brightness == Brightness.dark,
      p = DeckPalette.values[appearance.palette]!;
  final mode = dark ? Brightness.dark : Brightness.light;
  final ink = Color(dark ? p.darkInk : p.ink),
      accent = Color(dark ? p.darkAccent : p.accent),
      background = Color(dark ? p.darkBackground : p.background),
      hero = Color(dark ? p.darkHero : p.hero),
      surface = Color.lerp(background, ink, .035)!;
  final border = game ? accent : Color.lerp(background, ink, .22)!;
  final control = [surface, background].fold(
    border,
    (kept, ground) => ensureContrast(kept, ground, minimum: aaLarge),
  );
  final heading = appearance.skin == 'cyber'
      ? 'ChakraPetch'
      : appearance.skin == 'orbital' || game
      ? 'Rajdhani'
      : 'BricolageGrotesque';
  final style = DeckStyle(
    shape: appearance.shape,
    signal: dark ? Color(p.signal) : ink,
    headingFont: heading,
    compact: appearance.compact,
    borderWidth: game ? 3 : 1,
    glow: game ? accent.withValues(alpha: .6) : null,
    skin: appearance.skin,
  );
  final seeded = ColorScheme.fromSeed(seedColor: accent, brightness: mode)
      .copyWith(
        primary: accent,
        onPrimary: onColorFor(accent, dark: Color(p.darkBackground)),
        secondary: hero,
        onSecondary: ink,
        surface: surface,
        onSurface: ink,
        outline: border,
        surfaceContainerHighest: hero,
      );
  final scheme = withSurfaceTokens(
    seeded,
    background: background,
    ink: ink,
    hero: hero,
  );
  final base = _deckBase(appearance, mode, scheme, background);
  final scale = appearance.large ? 1.15 : 1.0;
  final themed = ['cyber', 'orbital', 'game'].contains(appearance.skin);
  final buttonText = TextStyle(
    fontFamily: themed ? heading : deckFontFamily(appearance.font),
    fontFamilyFallback: deckSymbolFallback,
    fontSize: 15 * scale,
    fontWeight: FontWeight.w700,
    letterSpacing: themed ? 1 : 0,
  );
  final text = base.textTheme.apply(bodyColor: ink, displayColor: ink);
  return base.copyWith(
    extensions: [style],
    hintColor: scheme.onSurfaceVariant,
    textTheme: deckDeckTextTheme(text, heading, scale, themed),
    dividerColor: border,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      centerTitle: false,
    ),
    filledButtonTheme: deckFilledButtonTheme(style, buttonText),
    outlinedButtonTheme: deckOutlinedButtonTheme(
      style,
      buttonText,
      ink,
      control,
    ),
    textButtonTheme: deckTextButtonTheme(dark ? accent : ink, buttonText),
    inputDecorationTheme: deckInputTheme(appearance, surface, control),
    navigationBarTheme: deckNavigationBarTheme(appearance, background, hero),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: style.border(border),
    ),
    snackBarTheme: deckSnackBarTheme(appearance, ink, background),
    chipTheme: deckChipTheme(base.chipTheme, appearance, border),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      contentTextStyle: text.bodyMedium,
      dividerColor: border,
    ),
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
  fontFamily: deckFontFamily(appearance.font),
  fontFamilyFallback: deckSymbolFallback,
  visualDensity: appearance.compact
      ? VisualDensity.compact
      : VisualDensity.standard,
);
