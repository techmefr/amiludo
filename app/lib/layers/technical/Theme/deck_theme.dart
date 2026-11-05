import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_component_themes.dart';
import 'package:amiludo/layers/technical/Theme/deck_palette.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';

export 'package:amiludo/layers/technical/Theme/deck_palette.dart';
export 'package:amiludo/layers/technical/Theme/deck_style.dart';

const deckSymbolFallback = ['NotoSansSymbols2', 'NotoSansSymbols'];

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
    fontFamilyFallback: deckSymbolFallback,
    fontSize: 15 * scale,
    fontWeight: FontWeight.w700,
    letterSpacing: themed ? 1 : 0,
  );
  final text = base.textTheme.apply(bodyColor: ink, displayColor: ink);
  return base.copyWith(
    extensions: [style],
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
      border,
    ),
    textButtonTheme: deckTextButtonTheme(dark ? accent : ink, buttonText),
    inputDecorationTheme: deckInputTheme(appearance, surface, border),
    navigationBarTheme: deckNavigationBarTheme(appearance, background, hero),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: style.border(border),
    ),
    snackBarTheme: deckSnackBarTheme(appearance, ink, background),
    chipTheme: deckChipTheme(base.chipTheme, appearance, border),
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
  fontFamilyFallback: deckSymbolFallback,
  visualDensity: appearance.compact
      ? VisualDensity.compact
      : VisualDensity.standard,
);
