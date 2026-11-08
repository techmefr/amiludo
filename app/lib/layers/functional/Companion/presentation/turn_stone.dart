import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

enum TurnStoneState { past, active, upcoming }

class TurnStone extends StatelessWidget {
  const TurnStone({
    super.key,
    required this.label,
    required this.state,
    required this.accent,
    this.index,
  });
  final String label;
  final TurnStoneState state;
  final Color accent;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final active = state == TurnStoneState.active;
    final past = state == TurnStoneState.past;
    return Semantics(
      selected: active,
      label: label,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: Motion.of(context, Motion.base),
          curve: Motion.curve,
          padding: EdgeInsets.symmetric(
            horizontal: active ? Space.xl : Space.lg,
            vertical: active ? Space.md : Space.sm,
          ),
          decoration: BoxDecoration(
            color: active ? accent : StonePalette.stone,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(
              color: active ? StonePalette.gold : StonePalette.edge,
              width: 2,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: .5),
                      blurRadius: Space.lg,
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (past)
                const DeckIcon(Icons.check, size: 18, color: StonePalette.heal)
              else if (index != null)
                Text(
                  '$index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: StonePalette.gold,
                    fontFeatures: Numerals.tabular,
                  ),
                ),
              const SizedBox(width: Space.sm),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: StonePalette.cream.withValues(
                      alpha: past ? .6 : 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
