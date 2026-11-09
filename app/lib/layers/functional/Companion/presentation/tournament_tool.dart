import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/bracket.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class TournamentTool extends StatefulWidget {
  const TournamentTool({super.key, required this.names});
  final List<String> names;

  @override
  State<TournamentTool> createState() => _TournamentToolState();
}

class _TournamentToolState extends State<TournamentTool> {
  late Bracket bracket = Bracket.seed(widget.names);
  final tool = toolThemeFor('tournament');

  void _win(int round, int match, int side) {
    tool.signal();
    setState(() => bracket = bracket.win(round, match, side));
  }

  Widget _side(int round, int match, int side, String? name) {
    final picked =
        bracket.decided(round, match) &&
        bracket.rounds[round + 1][match] == name;
    return Expanded(
      child: OutlinedButton(
        onPressed: name == null ? null : () => _win(round, match, side),
        style: OutlinedButton.styleFrom(
          backgroundColor: picked ? tool.accent.withValues(alpha: .25) : null,
          minimumSize: const Size(0, Targets.minimum),
        ),
        child: Text(name ?? '–', overflow: TextOverflow.ellipsis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final champion = bracket.champion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (champion != null) ...[
          Semantics(
            liveRegion: true,
            child: StoneSlab(
              accent: StonePalette.gold,
              halo: StonePalette.gold,
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Text(
                  l.tournamentChampion(champion),
                  textAlign: TextAlign.center,
                  style: theme.headlineSmall?.copyWith(
                    color: StonePalette.cream,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
        ],
        for (var r = 0; r < bracket.rounds.length - 1; r++) ...[
          Text(l.tournamentRound(r + 1), style: theme.titleMedium),
          const SizedBox(height: Space.sm),
          for (var m = 0; m < bracket.matches(r); m++)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.sm),
              child: Row(
                children: [
                  _side(r, m, 0, bracket.pairing(r, m).$1),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Space.sm),
                    child: Text('vs'),
                  ),
                  _side(r, m, 1, bracket.pairing(r, m).$2),
                ],
              ),
            ),
          const SizedBox(height: Space.md),
        ],
        TextButton(
          onPressed: () =>
              setState(() => bracket = Bracket.seed(widget.names)),
          child: Text(l.appearanceReset),
        ),
      ],
    );
  }
}
