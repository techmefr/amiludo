import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/clean/clean_components.dart';
import 'package:amiludo/layers/technical/Theme/clean/clean_text.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/deck_palette.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _symbols = ['Roboto', 'NotoSansSymbols2', 'NotoSansSymbols'];

CleanColors cleanColors(Appearance appearance, Brightness mode) {
  final dark = mode == Brightness.dark;
  final p = DeckPalette.values[appearance.palette]!;
  final ink = Color(dark ? p.darkInk : p.ink);
  final accent = Color(dark ? p.darkAccent : p.accent);
  final background = Color(dark ? p.darkBackground : p.background);
  final surface = Color(dark ? p.darkHero : p.hero);
  return CleanColors(
    ink: ink,
    secondary: ink.withValues(alpha: .68),
    accent: accent,
    onAccent: readableOn(accent),
    background: background,
    surface: surface,
    fill: Color.alphaBlend(ink.withValues(alpha: .12), background),
    separator: ink.withValues(alpha: .16),
    positive: appearance.palette == 'clean' ? Color(p.signal) : accent,
  );
}

ThemeData cleanTheme(Appearance appearance, Brightness mode) {
  final c = cleanColors(appearance, mode);
  final dark = mode == Brightness.dark;
  final scale = appearance.large ? 1.15 : 1.0;
  final scheme = ColorScheme.fromSeed(seedColor: c.accent, brightness: mode)
      .copyWith(
        primary: c.accent,
        onPrimary: c.onAccent,
        secondary: c.tint,
        onSecondary: c.ink,
        secondaryContainer: c.tint,
        onSecondaryContainer: c.accent,
        surface: c.surface,
        onSurface: c.ink,
        onSurfaceVariant: c.secondary,
        outline: c.separator,
        outlineVariant: c.separator,
        surfaceContainerHighest: c.fill,
        error: dark ? const Color(0xffFF6961) : const Color(0xffD70015),
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: mode,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    fontFamily: deckFontFamily(appearance.font),
    fontFamilyFallback: _symbols,
    splashFactory: NoSplash.splashFactory,
    highlightColor: c.ink.withValues(alpha: .06),
    visualDensity: appearance.compact
        ? VisualDensity.compact
        : VisualDensity.standard,
  );
  final text = cleanTextTheme(base.textTheme, c.ink, c.secondary, scale);
  return base.copyWith(
    extensions: [
      DeckStyle(
        shape: 'round',
        signal: c.ink,
        headingFont: appearance.font,
        compact: appearance.compact,
        clean: true,
      ),
    ],
    textTheme: text,
    dividerColor: c.separator,
    dividerTheme: DividerThemeData(
      color: c.separator,
      thickness: Hairline.width,
      space: Hairline.width,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background.withValues(alpha: Hairline.barOpacity),
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      iconTheme: IconThemeData(color: c.accent),
      actionsIconTheme: IconThemeData(color: c.accent),
      titleTextStyle: text.titleMedium,
    ),
    filledButtonTheme: cleanFilledButton(text.labelLarge!),
    outlinedButtonTheme: cleanTintedButton(c, text.labelLarge!),
    textButtonTheme: cleanPlainButton(c, text.labelLarge!),
    inputDecorationTheme: cleanInput(c),
    navigationBarTheme: cleanNavigationBar(c, text),
    switchTheme: cleanSwitch(c),
    bottomSheetTheme: cleanSheet(c),
    chipTheme: cleanChip(c, text.labelMedium!),
    segmentedButtonTheme: cleanSegmented(c),
    listTileTheme: ListTileThemeData(
      iconColor: c.accent,
      textColor: c.ink,
      contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.group),
      ),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.group),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: text.bodyMedium!.copyWith(color: c.background),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
      ),
    ),
  );
}
