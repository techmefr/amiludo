import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Templates/presentation/brick_settings_sheet.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class BrickChoice {
  const BrickChoice(this.id, this.settings);
  final String id;
  final CounterSettings settings;
}

const brickChoices = [
  BrickChoice('life', lifePreset),
  BrickChoice('points', pointsPreset),
  BrickChoice('chips', chipsPreset),
  BrickChoice('pot', potPreset),
];

class BricksStage extends StatelessWidget {
  const BricksStage({super.key, required this.bricks, required this.refresh});
  final List<Brick> bricks;
  final void Function(VoidCallback) refresh;

  String _label(BuildContext context, String id) {
    final l = context.l10n;
    return switch (id) {
      'life' => l.brickLife,
      'points' => l.brickPoints,
      'chips' => l.brickChips,
      _ => l.brickPot,
    };
  }

  Brick? _find(String id) => bricks.where((b) => b.id == id).firstOrNull;

  void _toggle(Brick brick, bool on) => refresh(() {
    bricks.removeWhere((b) => b.id == brick.id);
    if (on) bricks.add(brick);
  });

  Future<void> _edit(BuildContext context, Brick brick) async {
    final next = await showBrickSettings(
      context,
      CounterSettings.fromJson(brick.settings),
    );
    if (next == null) return;
    refresh(() {
      final at = bricks.indexWhere((b) => b.id == brick.id);
      if (at >= 0) bricks[at] = brick.copyWith(settings: next.toJson());
    });
  }

  Widget _counterChip(BuildContext context, BrickChoice choice) {
    final label = _label(context, choice.id);
    final brick = _find(choice.id);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterChip(
          label: Text(label),
          selected: brick != null,
          onSelected: (on) => _toggle(
            Brick(
              id: choice.id,
              type: 'counter',
              settings: choice.settings.toJson(),
            ),
            on,
          ),
        ),
        if (brick != null)
          IconButton(
            tooltip: '$label - ${context.l10n.brickSettings}',
            onPressed: () => _edit(context, brick),
            icon: const Icon(Icons.tune),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Space.sm,
    runSpacing: Space.sm,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final choice in brickChoices) _counterChip(context, choice),
      for (final tool in toolDefinitions)
        FilterChip(
          label: Text(context.toolTitle(tool.id)),
          selected: _find(tool.id) != null,
          onSelected: (on) => _toggle(Brick(id: tool.id, type: tool.id), on),
        ),
    ],
  );
}
