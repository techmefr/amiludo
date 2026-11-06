import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
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

  void _toggle(BrickChoice choice, bool on) => refresh(() {
    bricks.removeWhere((b) => b.id == choice.id);
    if (on) {
      bricks.add(
        Brick(
          id: choice.id,
          type: 'counter',
          settings: choice.settings.toJson(),
        ),
      );
    }
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Space.sm,
    runSpacing: Space.sm,
    children: [
      for (final choice in brickChoices)
        FilterChip(
          label: Text(_label(context, choice.id)),
          selected: bricks.any((b) => b.id == choice.id),
          onSelected: (on) => _toggle(choice, on),
        ),
    ],
  );
}
