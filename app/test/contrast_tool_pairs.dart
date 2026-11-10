import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/tool_category_tile.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_frame.dart';
import 'package:amiludo/layers/technical/Theme/game_art_3d.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

import 'contrast_pairs.dart';

const _mixes = <double?>[null, .1, .16, .18, .22, .24, .3];
const _cardKinds = [
  'dice',
  'picker',
  'teams',
  'scores',
  'timer',
  'wheel',
  'order',
  'unknown',
];

List<Pair> tintedPairs(ThemeData theme, String id, ToolTheme tool) {
  final s = theme.colorScheme;
  return [
    for (final mix in _mixes) ...[
      Pair(
        '$id ink@$mix',
        tool.ink(tool.surfaceOn(theme, mix: mix)),
        tool.surfaceOn(theme, mix: mix),
      ),
      Pair('$id onSurface@$mix', s.onSurface, tool.surfaceOn(theme, mix: mix)),
      if (mix == null)
        Pair(
          '$id variant@$mix',
          s.onSurfaceVariant,
          tool.surfaceOn(theme, mix: mix),
        ),
    ],
  ];
}

List<Pair> framePairs(ThemeData theme, String id, ToolTheme tool) {
  final framed = toolFrameTheme(theme, tool);
  final page = framed.scaffoldBackgroundColor;
  return [
    for (final pair in [
      ...schemePairs(framed),
      ...textPairs(framed),
      ...componentPairs(framed),
    ])
      Pair(
        '$id frame ${pair.name}',
        pair.foreground,
        pair.background,
        pair.minimum,
      ),
    Pair('$id frame ink', framed.colorScheme.primary, page),
  ];
}

List<Pair> shelfPairs(ThemeData theme) => [
  for (final entry in toolShelfStyles.entries) ...[
    Pair(
      '${entry.key} shelf ink',
      entry.value.theme.ink(entry.value.theme.surfaceOn(theme, mix: .24)),
      entry.value.theme.surfaceOn(theme, mix: .24),
    ),
  ],
  for (final kind in _cardKinds) ...[
    Pair(
      '$kind card text',
      GameCardStyle.foreground(GameCardStyle.background(kind)),
      GameCardStyle.background(kind),
    ),
    Pair(
      '$kind card lit text',
      GameCardStyle.foreground(GameCardStyle.background(kind)),
      GameCardStyle.highlight(GameCardStyle.background(kind)),
    ),
  ],
];
