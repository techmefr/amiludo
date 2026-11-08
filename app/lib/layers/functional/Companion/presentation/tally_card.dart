import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TallyCard extends StatelessWidget {
  const TallyCard({
    super.key,
    required this.name,
    required this.counters,
    required this.values,
    required this.accent,
    required this.onBump,
  });
  final String name;
  final List<String> counters;
  final List<int> values;
  final Color accent;
  final void Function(int counter, int delta) onBump;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    return StoneSlab(
      accent: accent,
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.titleMedium?.copyWith(color: StonePalette.gold),
            ),
            for (final (c, label) in counters.indexed)
              Semantics(
                container: true,
                label: '$name $label ${values[c]}',
                child: Row(
                  children: [
                    Expanded(
                      child: ExcludeSemantics(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodyLarge?.copyWith(
                            color: StonePalette.cream,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '${l.counterDecrease} $label $name',
                      onPressed: () => onBump(c, -1),
                      icon: const DeckIcon(Icons.remove),
                    ),
                    SizedBox(
                      width: Space.xxl + Space.lg,
                      child: ExcludeSemantics(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${values[c]}',
                            textAlign: TextAlign.center,
                            style: stoneNumerals(TypeScale.headline),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '${l.counterIncrease} $label $name',
                      onPressed: () => onBump(c, 1),
                      icon: const DeckIcon(Icons.add),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
