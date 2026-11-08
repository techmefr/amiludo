import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Combat/domain/entities/encounter.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class CombatHeader extends StatelessWidget {
  const CombatHeader({
    super.key,
    required this.encounter,
    required this.tool,
    required this.onAdd,
    required this.onStart,
    required this.onNext,
    required this.onRoll,
    required this.onReset,
  });
  final Encounter encounter;
  final ToolTheme tool;
  final VoidCallback onAdd, onStart, onNext, onRoll, onReset;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final surface = tool.surface(context, mix: .22);
    final ink = tool.ink(surface);
    final text = Theme.of(context).textTheme;
    final turn = encounter.current;
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            container: true,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    l.combatRound(encounter.round),
                    overflow: TextOverflow.ellipsis,
                    style: Numerals.instrument(
                      text.headlineMedium,
                    )?.copyWith(color: ink),
                  ),
                ),
                const SizedBox(width: Space.md),
                if (turn != null)
                  Expanded(
                    child: Text(
                      l.combatTurnOf(turn.name),
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(color: ink),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              if (encounter.started)
                FilledButton.icon(
                  onPressed: onNext,
                  icon: const DeckIcon(Icons.chevron_right),
                  label: Text(l.combatNext),
                )
              else
                FilledButton.icon(
                  onPressed: encounter.isEmpty ? null : onStart,
                  icon: const DeckIcon(Icons.play_arrow),
                  label: Text(l.combatStart),
                ),
              OutlinedButton.icon(
                onPressed: encounter.isEmpty ? null : onRoll,
                icon: const DeckIcon(Icons.casino_outlined),
                label: Text(l.combatRoll),
              ),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const DeckIcon(Icons.add),
                label: Text(l.combatAdd),
              ),
              if (encounter.started)
                TextButton(onPressed: onReset, child: Text(l.combatReset)),
            ],
          ),
        ],
      ),
    );
  }
}
