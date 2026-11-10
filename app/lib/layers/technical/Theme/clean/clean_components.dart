import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CleanColors {
  const CleanColors({
    required this.ink,
    required this.secondary,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.fill,
    required this.separator,
    required this.positive,
  });
  final Color ink,
      secondary,
      accent,
      accentText,
      onAccent,
      background,
      surface,
      fill,
      separator,
      positive;
  Color get tint => Color.alphaBlend(accent.withValues(alpha: .08), background);
}

const _pill = StadiumBorder();

FilledButtonThemeData cleanFilledButton(TextStyle text) =>
    FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(Targets.minimum, 50),
        padding: const EdgeInsets.symmetric(horizontal: Space.xl),
        shape: _pill,
        elevation: 0,
        textStyle: text,
      ),
    );

OutlinedButtonThemeData cleanTintedButton(CleanColors c, TextStyle text) =>
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(Targets.minimum, 50),
        padding: const EdgeInsets.symmetric(horizontal: Space.xl),
        backgroundColor: c.tint,
        foregroundColor: c.accentText,
        side: BorderSide.none,
        shape: _pill,
        textStyle: text,
      ),
    );

TextButtonThemeData cleanPlainButton(CleanColors c, TextStyle text) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(Targets.minimum, Targets.minimum),
        foregroundColor: c.accentText,
        shape: _pill,
        textStyle: text,
      ),
    );

InputDecorationTheme cleanInput(CleanColors c) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(Radii.md),
    borderSide: width == 0
        ? BorderSide.none
        : BorderSide(color: color, width: width),
  );
  final edge = [c.surface, c.background].fold(
    c.separator,
    (kept, ground) => ensureContrast(kept, ground, minimum: aaLarge),
  );
  return InputDecorationTheme(
    filled: true,
    fillColor: c.surface,
    border: border(edge, 1),
    enabledBorder: border(edge, 1),
    focusedBorder: border(c.accent, 2),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Space.lg,
      vertical: Space.md,
    ),
  );
}

NavigationBarThemeData cleanNavigationBar(CleanColors c, TextTheme text) {
  Color tone(Set<WidgetState> s) =>
      s.contains(WidgetState.selected) ? c.accentText : c.secondary;
  return NavigationBarThemeData(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    height: 60,
    indicatorColor: Colors.transparent,
    iconTheme: WidgetStateProperty.resolveWith(
      (s) => IconThemeData(color: tone(s)),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => text.labelSmall!.copyWith(color: tone(s)),
    ),
  );
}

SwitchThemeData cleanSwitch(CleanColors c) => SwitchThemeData(
  thumbColor: const WidgetStatePropertyAll(Colors.white),
  trackColor: WidgetStateProperty.resolveWith(
    (s) => s.contains(WidgetState.selected) ? c.positive : c.fill,
  ),
  trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
);

BottomSheetThemeData cleanSheet(CleanColors c) => BottomSheetThemeData(
  backgroundColor: c.surface,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  showDragHandle: true,
  dragHandleColor: c.secondary.withValues(alpha: .5),
  dragHandleSize: const Size(36, 5),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.group)),
  ),
);

ChipThemeData cleanChip(CleanColors c, TextStyle label) => ChipThemeData(
  shape: _pill,
  side: BorderSide.none,
  backgroundColor: c.fill,
  selectedColor: c.accent,
  checkmarkColor: c.onAccent,
  labelStyle: label.copyWith(color: c.ink),
  secondaryLabelStyle: label.copyWith(color: c.onAccent),
);

SegmentedButtonThemeData cleanSegmented(CleanColors c) =>
    SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: c.fill,
        foregroundColor: c.ink,
        selectedBackgroundColor: c.accent,
        selectedForegroundColor: c.onAccent,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
    );
