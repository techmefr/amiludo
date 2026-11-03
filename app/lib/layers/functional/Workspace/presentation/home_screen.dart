import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/cubit/workspace_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ws = context.watch<WorkspaceCubit>().state.workspace,
        theme = Theme.of(context),
        current = ws.current;
    final finished = ws.games
        .where((g) => g.finishedAt != null)
        .take(3)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: tr(
            context,
            'Jouez ensemble / restez dans la partie',
            'Play together / stay in the game',
          ),
          title: tr(
            context,
            'On joue à quoi, aujourd’hui ?',
            'What are we playing today?',
          ),
          subtitle: tr(
            context,
            'Les bons outils. La bonne compagnie. Vos vraies parties.',
            'The right tools. Good company. Your actual games.',
          ),
          action: OutlinedButton.icon(
            onPressed: () => context.push(GameSetupRequest.path),
            icon: const DeckIcon(Icons.add, size: 18),
            label: Text(tr(context, 'Nouvelle partie', 'New game')),
          ),
        ),
        DeckPanel(
          color: theme.colorScheme.surfaceContainerHighest,
          child: LayoutBuilder(
            builder: (context, c) => Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.maxWidth <= 650) const GameArt(height: 180),
                      Text(
                        tr(
                          context,
                          'Les bons outils, la bonne compagnie',
                          'Good tools. Great company.',
                        ).toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(
                          context,
                          'Une table, des amis.\nÀ vous de jouer !',
                          'Your friends, your table.\nLet’s play!',
                        ),
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr(
                          context,
                          'Scores, hasard et tempo :\ngardez l’esprit dans la partie.',
                          'Scores, chance and timing:\nkeep your mind in the game.',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => context.go('/tools'),
                            icon: const DeckIcon(Icons.arrow_outward, size: 18),
                            label: Text(tr(context, 'Mode libre', 'Free mode')),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/templates'),
                            icon: const DeckIcon(
                              Icons.dashboard_outlined,
                              size: 18,
                            ),
                            label: Text(
                              tr(
                                context,
                                'Mes compagnons par jeu',
                                'My game companions',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (c.maxWidth > 650)
                  const SizedBox(width: 320, child: GameArt(height: 260)),
              ],
            ),
          ),
        ),
        if (current != null && current.finishedAt == null) ...[
          SectionHeading(
            tr(context, 'La partie continue', 'Your game continues'),
            action: TextButton(
              onPressed: () => context.go('/game'),
              child: const Text('→'),
            ),
          ),
          DeckPanel(
            highlight: true,
            child: Wrap(
              spacing: 24,
              runSpacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(current.title, style: theme.textTheme.titleLarge),
                    Text(
                      '${current.players.length} joueurs · Manche ${current.round} · ${current.players[current.activeIndex].name}',
                    ),
                  ],
                ),
                FilledButton(
                  onPressed: () => context.go('/game'),
                  child: Text(
                    tr(context, 'Reprendre la partie', 'Resume game'),
                  ),
                ),
              ],
            ),
          ),
        ],
        SectionHeading(
          tr(context, 'Les outils de la table', 'Tools for your table'),
          action: TextButton(
            onPressed: () => context.go('/tools'),
            child: Text(tr(context, 'Tout voir ↗', 'View all ↗')),
          ),
        ),
        ResponsiveGrid(
          minimumWidth: MediaQuery.sizeOf(context).width < 760 ? 150 : 280,
          children: toolDefinitions
              .where((t) => ws.favorites.contains(t.id))
              .map(
                (t) => DeckPanel(
                  padding: 20,
                  color: toolSurface(context, t.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GameArt(tool: t.id, height: 112),
                      const SizedBox(height: 20),
                      Text(t.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(t.subtitle),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.push('/tools/${t.id}'),
                        child: Text(tr(context, 'Ouvrir ↗', 'Open ↗')),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        SectionHeading(
          tr(context, 'Vos derniers bons moments', 'Recent good times'),
          action: TextButton(
            onPressed: () => context.go('/history'),
            child: Text(tr(context, 'Historique ↗', 'History ↗')),
          ),
        ),
        if (finished.isEmpty)
          EmptyPanel(
            title: tr(
              context,
              'La première partie vous attend',
              'Your first game awaits',
            ),
            message: tr(
              context,
              'Vos résultats apparaîtront ici. Aucune partie fictive.',
              'Your real results will appear here.',
            ),
          ),
        for (final g in finished)
          Padding(
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
          ),
      ],
    );
  }
}
