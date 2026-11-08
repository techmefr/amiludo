import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/life_match.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_panel_parts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _lowLife = 5;

class LifePanel extends StatelessWidget {
  const LifePanel({
    super.key,
    required this.player,
    required this.accent,
    required this.onChange,
    required this.onDetails,
  });
  final LifePlayer player;
  final Color accent;
  final void Function(int delta) onChange;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final out = player.out;
    final halo = out
        ? StonePalette.danger
        : (player.life <= _lowLife ? StonePalette.ember : null);
    return Padding(
      padding: const EdgeInsets.all(Space.xs),
      child: StoneSlab(
        accent: accent,
        halo: halo,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                LifeHalf(
                  label: '${l.counterDecrease} ${player.name}',
                  icon: Icons.remove,
                  onTap: () => onChange(-1),
                  onHold: () => onChange(-lifeBigStep),
                ),
                LifeHalf(
                  label: '${l.counterIncrease} ${player.name}',
                  icon: Icons.add,
                  onTap: () => onChange(1),
                  onHold: () => onChange(lifeBigStep),
                ),
              ],
            ),
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Semantics(
                    liveRegion: true,
                    label: '${player.name} ${player.life}',
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${player.life}',
                                style: stoneNumerals(TypeScale.display * 3)
                                    .copyWith(
                                      color: out
                                          ? StonePalette.cream.withValues(
                                              alpha: .45,
                                            )
                                          : StonePalette.cream,
                                    ),
                              ),
                            ),
                          ),
                          if (out)
                            Text(
                              l.counterEliminated,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: StonePalette.cream,
                              ),
                            )
                          else
                            LifeMarks(player: player),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: Space.sm,
              left: Targets.minimum,
              right: Targets.minimum,
              child: IgnorePointer(
                child: Text(
                  player.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: StonePalette.cream,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: l.lifeDetailsFor(player.name),
                constraints: const BoxConstraints(
                  minWidth: Targets.minimum,
                  minHeight: Targets.minimum,
                ),
                onPressed: onDetails,
                icon: const DeckIcon(Icons.tune),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
