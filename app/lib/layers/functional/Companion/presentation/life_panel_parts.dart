import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/life_match.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const lifeBigStep = 5;

class LifeHalf extends StatelessWidget {
  const LifeHalf({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.onHold,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap, onHold;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        onLongPress: onHold,
        child: Align(
          alignment: icon == Icons.remove
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: ExcludeSemantics(
              child: DeckIcon(
                icon,
                size: 36,
                color: const Color(0xffffffff).withValues(alpha: .8),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class LifeMarks extends StatelessWidget {
  const LifeMarks({super.key, required this.player});
  final LifePlayer player;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final worst = player.commander.values.fold<int>(0, (a, b) => a > b ? a : b);
    final marks = <(IconData, String, int)>[
      if (player.poison > 0)
        (Icons.coronavirus_outlined, l.lifePoison, player.poison),
      if (player.energy > 0) (Icons.bolt, l.lifeEnergy, player.energy),
      if (worst > 0) (Icons.shield_outlined, l.lifeCommander, worst),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Space.md,
      children: [
        for (final (icon, label, value) in marks)
          Semantics(
            label: '$label $value',
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DeckIcon(icon, size: 18, color: StonePalette.gold),
                  const SizedBox(width: Space.xs),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: StonePalette.cream,
                      fontFeatures: Numerals.tabular,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
