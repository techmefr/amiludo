import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
        const _HeroPanel(),
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
        ResponsiveGrid(
          minimumWidth: MediaQuery.sizeOf(context).width < 760 ? 150 : 280,
          children: toolDefinitions
              .where((t) => ws.favorites.contains(t.id))
              .map((t) => _ToolCard(tool: t))
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
      action: OutlinedButton.icon(
        onPressed: () => context.push(GameSetupRequest.path),
        icon: const DeckIcon(Icons.add, size: 18),
        label: Text(context.l10n.workspaceNewGame),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();
  @override
  Widget build(BuildContext context) {
    return DeckPanel(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: LayoutBuilder(
        builder: (context, c) => Row(
          children: [
            Expanded(child: _HeroText(compact: c.maxWidth <= 650)),
            if (c.maxWidth > 650)
              const SizedBox(width: 320, child: GameArt(height: 260)),
          ],
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact) const GameArt(height: 180),
        Text(
          context.l10n.workspaceGoodToolsGreatCompany.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.workspaceYourFriendsYourTableLet,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(context.l10n.workspaceScoresChanceAndTimingKeep),
        const SizedBox(height: 24),
        const _HeroActions(),
      ],
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => context.go('/tools'),
          icon: const DeckIcon(Icons.arrow_outward, size: 18),
          label: Text(context.l10n.workspaceFreeMode),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/templates'),
          icon: const DeckIcon(Icons.dashboard_outlined, size: 18),
          label: Text(context.l10n.workspaceMyGameCompanions),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/lobby'),
          icon: const DeckIcon(Icons.wifi_tethering, size: 18),
          label: Text(context.l10n.workspaceOpenALobby),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/join'),
          icon: const DeckIcon(Icons.login, size: 18),
          label: Text(context.l10n.workspaceJoinAGame),
        ),
      ],
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
                '${game.players.length} joueurs · Manche ${game.round} · ${game.players[game.activeIndex].name}',
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

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final ToolDefinition tool;
  @override
  Widget build(BuildContext context) {
    return DeckPanel(
      padding: 20,
      color: toolSurface(context, tool.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameArt(tool: tool.id, height: 112),
          const SizedBox(height: 20),
          Text(tool.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(tool.subtitle),
          const SizedBox(height: 16),
          const Spacer(),
          OutlinedButton(
            onPressed: () => context.push('/tools/${tool.id}'),
            child: Text(context.l10n.workspaceOpen),
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
              color: theme.colorScheme.primary,
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
