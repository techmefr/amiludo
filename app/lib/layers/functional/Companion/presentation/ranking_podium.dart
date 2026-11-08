import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/ranking.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

String rankingScoreText(num value) =>
    value == value.roundToDouble() ? '${value.toInt()}' : '$value';

class RankingPodium extends StatelessWidget {
  const RankingPodium({super.key, required this.ranking});
  final List<RankedPlayer> ranking;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    if (ranking.isEmpty) return Text(l.rankingEmpty, style: theme.bodyLarge);
    final top = winners(ranking);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          liveRegion: true,
          child: StoneSlab(
            accent: StonePalette.gold,
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                children: [
                  Transform.rotate(
                    angle: -.12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.md,
                        vertical: Space.xs,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: StonePalette.danger, width: 3),
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                      child: Text(
                        top.length > 1 ? l.rankingTie : l.rankingStamp,
                        style: theme.titleMedium?.copyWith(
                          color: StonePalette.danger,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Text(
                      top.map((p) => p.name).join(' · '),
                      style: theme.headlineSmall?.copyWith(
                        color: StonePalette.cream,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        for (final p in ranking)
          Semantics(
            container: true,
            label:
                '${l.rankingPosition(p.rank)} ${p.name} ${rankingScoreText(p.score)}',
            child: ExcludeSemantics(
              child: ListTile(
                leading: CircleAvatar(child: Text('${p.rank}')),
                title: Text(p.name),
                subtitle: p.tied ? Text(l.rankingTie) : null,
                trailing: Text(
                  rankingScoreText(p.score),
                  style: theme.titleLarge?.copyWith(
                    fontFeatures: Numerals.tabular,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
