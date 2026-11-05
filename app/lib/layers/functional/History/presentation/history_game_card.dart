import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/History/presentation/cubit/history_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class HistoryGameCard extends StatelessWidget {
  const HistoryGameCard({super.key, required this.game});
  final GameSession game;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), g = game;
    final headline = g.cooperative
        ? '${context.l10n.historyTeam} : ${numberText(g.players.fold<double>(0, (sum, p) => sum + g.score(p.id)))} / ${numberText(g.target)}'
        : '${g.finishedAt == null ? context.l10n.historyLeading : context.l10n.historyWinner} : ${g.winners.map((p) => p.name).join(' & ')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DeckPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(g.title, style: theme.textTheme.headlineMedium),
                Chip(
                  label: Text(
                    g.finishedAt == null
                        ? context.l10n.historyActive
                        : context.l10n.historyComplete,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${DateTime.fromMillisecondsSinceEpoch(g.createdAt).toLocal().toString().substring(0, 16)} · ${g.players.length} ${context.l10n.gamePlayers} · ${g.round} ${context.l10n.historyRounds}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(headline, style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            for (final p in g.ranking)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(p.name)),
                    Text(
                      '${numberText(g.score(p.id))} pts',
                      style: const TextStyle(fontFamily: 'IBMPlexMono'),
                    ),
                  ],
                ),
              ),
            const Divider(height: 32),
            _CardActions(game: g),
          ],
        ),
      ),
    );
  }
}

class _CardActions extends StatelessWidget {
  const _CardActions({required this.game});
  final GameSession game;

  Future<void> _delete(BuildContext context) async {
    final controller = context.read<HistoryCubit>();
    if (await confirm(
      context,
      context.l10n.historyDeleteThisGame,
      context.l10n.historyThisAlsoRemovesScoresAnd,
    )) {
      await controller.deleteGame(game.id);
    }
  }

  Future<void> _resume(BuildContext context) async {
    await context.read<HistoryCubit>().chooseGame(game.id);
    if (context.mounted) context.go('/game');
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      FilledButton(
        onPressed: () => _resume(context),
        child: Text(
          game.finishedAt == null
              ? context.l10n.historyResume
              : context.l10n.historyDetails,
        ),
      ),
      OutlinedButton(
        onPressed: () => context.push(
          GameSetupRequest.path,
          extra: GameSetupRequest(
            names: game.players.map((p) => p.name).toList(),
          ),
        ),
        child: Text(context.l10n.historyPlayAgain),
      ),
      OutlinedButton(
        onPressed: () => context.push('/review/${game.id}'),
        child: Text(context.l10n.historyRate),
      ),
      OutlinedButton(
        onPressed: () => context.push('/memories/${game.id}'),
        child: Text(context.l10n.historyMemories),
      ),
      OutlinedButton(
        onPressed: () => FileTransfer.shareText(
          game.toCsv(),
          'scores-${game.id}.csv',
          mime: 'text/csv',
        ),
        child: const Text('CSV'),
      ),
      OutlinedButton(
        onPressed: () =>
            FileTransfer.shareText(game.export(), 'partie-${game.id}.json'),
        child: const Text('JSON'),
      ),
      IconButton(
        tooltip: context.l10n.historyDeleteGame,
        onPressed: () => _delete(context),
        icon: const DeckIcon(Icons.delete_outline),
      ),
    ],
  );
}
