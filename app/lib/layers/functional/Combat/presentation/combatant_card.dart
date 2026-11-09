import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Combat/domain/entities/combatant.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combat_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class CombatantCard extends StatelessWidget {
  const CombatantCard({
    super.key,
    required this.combatant,
    required this.active,
    required this.tool,
    required this.onOpen,
    required this.onHit,
  });
  final Combatant combatant;
  final bool active;
  final ToolTheme tool;
  final VoidCallback onOpen;
  final ValueChanged<int> onHit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final text = Theme.of(context).textTheme;
    final c = combatant;
    final label = [
      l.combatCardLabel(c.name, c.initiative ?? 0, c.hp, c.maxHp),
      if (active) l.combatTurnOf(c.name),
      if (c.down) l.combatDown,
    ].join(', ');
    return Semantics(
      container: true,
      label: label,
      child: AnimatedContainer(
        duration: tool.duration(context),
        curve: tool.curve,
        decoration: BoxDecoration(
          color: active ? tool.accent.withValues(alpha: .24) : surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: active ? tool.accent : scheme.outlineVariant,
            width: active ? 2.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.md),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: AnimatedSwitcher(
                    duration: tool.duration(context),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '${c.initiative ?? '–'}',
                      key: ValueKey(c.initiative),
                      textAlign: TextAlign.center,
                      style: Numerals.instrument(text.headlineMedium)
                          ?.copyWith(color: ink),
                    ),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: _Body(combatant: c, active: active, ink: ink),
                ),
                if (c.tracksHp) ...[
                  IconButton(
                    tooltip: l.combatHpMinus(c.name),
                    constraints: const BoxConstraints.tightFor(
                      width: Targets.minimum,
                      height: Targets.minimum,
                    ),
                    onPressed: () => onHit(-1),
                    icon: const DeckIcon(Icons.remove),
                  ),
                  IconButton(
                    tooltip: l.combatHpPlus(c.name),
                    constraints: const BoxConstraints.tightFor(
                      width: Targets.minimum,
                      height: Targets.minimum,
                    ),
                    onPressed: () => onHit(1),
                    icon: const DeckIcon(Icons.add),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.combatant,
    required this.active,
    required this.ink,
  });
  final Combatant combatant;
  final bool active;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final c = combatant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (active) ...[
              DeckIcon(Icons.play_arrow, color: ink),
              const SizedBox(width: Space.xs),
            ],
            Flexible(
              child: Text(
                c.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ink,
                  decoration: c.down ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (c.down) ...[
              const SizedBox(width: Space.sm),
              DeckIcon(Icons.heart_broken_outlined, color: ink),
              const SizedBox(width: Space.xs),
              Text(l.combatDown, style: TextStyle(color: ink)),
            ],
          ],
        ),
        if (c.tracksHp) ...[
          const SizedBox(height: Space.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: LinearProgressIndicator(
              value: c.health,
              minHeight: 8,
              color: c.health < .25 ? scheme.error : ink,
              backgroundColor: ink.withValues(alpha: .18),
            ),
          ),
          Text(
            '${c.hp} / ${c.maxHp}',
            style: Numerals.instrument(Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(color: ink),
          ),
        ],
        if (c.conditions.isNotEmpty)
          Wrap(
            spacing: Space.xs,
            children: [
              for (final key in c.conditions)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(context.combatCondition(key)),
                ),
            ],
          ),
      ],
    );
  }
}
