import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

import 'contrast_pairs.dart';
import 'contrast_tool_pairs.dart';

const skins = ['clean', 'play', 'cyber', 'orbital', 'paper', 'game'];
const modes = [Brightness.light, Brightness.dark];

List<Pair> themeFailures(ThemeData theme) => [
  for (final pair in [
    ...schemePairs(theme),
    ...textPairs(theme),
    ...componentPairs(theme),
    ...boundaryPairs(theme),
  ])
    if (!pair.passes) pair,
];

void main() {
  test('every universe palette keeps its theme pairs AA in both modes', () {
    final report = <String>[];
    for (final skin in skins) {
      for (final palette in Appearance.palettes) {
        for (final mode in modes) {
          final theme = deckTheme(
            Appearance(skin: skin, palette: palette),
            mode,
          );
          for (final pair in themeFailures(theme)) {
            report.add('$skin/$palette/${mode.name}: $pair');
          }
        }
      }
    }
    expect(report, isEmpty, reason: report.join('\n'));
  });

  test('every tool and shelf identity keeps its pairs AA everywhere', () {
    final report = <String>{};
    for (final skin in skins) {
      for (final palette in Appearance.palettes) {
        for (final mode in modes) {
          final theme = deckTheme(
            Appearance(skin: skin, palette: palette),
            mode,
          );
          final where = '$skin/$palette/${mode.name}';
          for (final pair in shelfPairs(theme)) {
            if (!pair.passes) report.add('$where: $pair');
          }
          for (final MapEntry(key: id, value: tool) in toolThemes.entries) {
            for (final pair in [
              ...tintedPairs(theme, id, tool),
              ...framePairs(theme, id, tool),
            ]) {
              if (!pair.passes) report.add('$where: $pair');
            }
          }
        }
      }
    }
    expect(report, isEmpty, reason: report.join('\n'));
  });
}
