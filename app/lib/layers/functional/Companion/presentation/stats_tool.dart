import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/play_stats.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class StatsTool extends StatelessWidget {
  const StatsTool({super.key, required this.games});
  final List<GameSession> games;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final players = playerRecords(games);
    final titles = gameRecords(games);
    final accent = toolThemeFor('stats').accent;
    if (players.isEmpty) {
      return Text(l.statsEmpty, style: theme.bodyLarge);
    }
    final total = titles.fold<int>(0, (sum, g) => sum + g.plays);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoneSlab(
          accent: accent,
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Row(
              children: [
                Text('$total', style: stoneNumerals(TypeScale.display * 1.6)),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Text(
                    l.statsGamesPlayed,
                    style: theme.titleMedium?.copyWith(
                      color: StonePalette.cream,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        Text(l.statsPlayers, style: theme.titleLarge),
        for (final p in players)
          Semantics(
            container: true,
            label: '${p.name} ${l.statsRecord(p.wins, p.played)}',
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(p.name, style: theme.bodyLarge)),
                        Text(
                          l.statsRecord(p.wins, p.played),
                          style: theme.bodyLarge?.copyWith(
                            fontFeatures: Numerals.tabular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.sm),
                      child: LinearProgressIndicator(
                        minHeight: Space.sm,
                        value: p.rate,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: Space.xl),
        Text(l.statsGames, style: theme.titleLarge),
        for (final g in titles)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(g.title),
            trailing: Text(l.statsPlays(g.plays)),
          ),
      ],
    );
  }
}
