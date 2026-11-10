import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/home_hero.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/home_tiles.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ws = context.watch<WorkspaceCubit>().state.workspace,
        current = ws.current;
    final finished = ws.games
        .where((g) => g.finishedAt != null)
        .take(3)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HomeHeading(),
        const HomeHero(),
        const SizedBox(height: Space.xl),
        const HomeWaysToPlay(),
        if (current != null && current.finishedAt == null) ...[
          SectionHeading(
            context.l10n.workspaceYourGameContinues,
            action: TextButton(
              onPressed: () => context.go('/game'),
              child: const Text('→'),
            ),
          ),
          _CurrentGamePanel(game: current),
        ],
        SectionHeading(
          context.l10n.workspaceToolsForYourTable,
          action: TextButton(
            onPressed: () => context.go('/tools'),
            child: Text(context.l10n.workspaceViewAll),
          ),
        ),
        HomeFavoriteTools(
          tools: toolDefinitions
              .where((t) => t.id != 'dice' && ws.favorites.contains(t.id))
              .toList(),
        ),
        SectionHeading(
          context.l10n.workspaceRecentGoodTimes,
          action: TextButton(
            onPressed: () => context.go('/history'),
            child: Text(context.l10n.workspaceHistory2),
          ),
        ),
        if (finished.isEmpty)
          EmptyPanel(
            title: context.l10n.workspaceYourFirstGameAwaits,
            message: context.l10n.workspaceYourRealResultsWillAppear,
          ),
        for (final g in finished) _FinishedGameRow(game: g),
      ],
    );
  }
}

class _HomeHeading extends StatelessWidget {
  const _HomeHeading();
  @override
  Widget build(BuildContext context) {
    return DeckHeading(
      eyebrow: context.l10n.workspacePlayTogetherStayInThe,
      title: context.l10n.workspaceWhatAreWePlayingToday,
      subtitle: context.l10n.workspaceTheRightToolsGoodCompany,
    );
  }
}

class _CurrentGamePanel extends StatelessWidget {
  const _CurrentGamePanel({required this.game});
  final GameSession game;
  @override
  Widget build(BuildContext context) {
    return DeckPanel(
      highlight: true,
      child: Wrap(
        spacing: 24,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.title, style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${game.players.length} ${context.l10n.gamePlayers} · ${context.l10n.gameRound} ${game.round} · ${game.players[game.activeIndex].name}',
              ),
            ],
          ),
          FilledButton(
            onPressed: () => context.go('/game'),
            child: Text(context.l10n.workspaceResumeGame),
          ),
        ],
      ),
    );
  }
}

class _FinishedGameRow extends StatelessWidget {
  const _FinishedGameRow({required this.game});
  final GameSession game;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), g = game;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DeckPanel(
        padding: 20,
        child: Row(
          children: [
            DeckIcon(
              Icons.emoji_events_outlined,
              color: theme.colorScheme.accentInk,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(g.title, style: theme.textTheme.titleMedium),
                  Text(
                    '${g.winners.map((p) => p.name).join(' & ')} · ${numberText(g.score(g.winners.first.id))} pts',
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.go('/history'),
              child: const Text('↗'),
            ),
          ],
        ),
      ),
    );
  }
}
