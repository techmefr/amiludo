import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/game_board.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.timer});
  final WidgetBuilder timer;

  String _subtitle(BuildContext context, GameSession g) {
    final rule = g.cooperative
        ? tr(context, 'Coopération', 'Cooperative')
        : g.lowestWins
        ? tr(context, 'Le moins de points gagne', 'Lowest score wins')
        : tr(context, 'Le plus de points gagne', 'Highest score wins');
    return '${g.players.length} ${tr(context, 'joueurs', 'players')} · ${tr(context, 'Manche', 'Round')} ${g.round} · $rule';
  }

  @override
  Widget build(BuildContext context) {
    final g = context.watch<GameCubit>().state.current;
    if (g == null) return const _NoGame();
    final board = GameBoard(game: g);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DeckHeading(
          eyebrow: g.finishedAt == null
              ? tr(
                  context,
                  'Partie en cours / données locales',
                  'Active game / local data',
                )
              : tr(context, 'Partie terminée', 'Completed game'),
          title: g.title,
          subtitle: _subtitle(context, g),
          action: g.finishedAt == null
              ? null
              : OutlinedButton(
                  onPressed: () =>
                      FileTransfer.shareText(g.export(), 'partie-${g.id}.json'),
                  child: Text(tr(context, 'Exporter', 'Export')),
                ),
        ),
        if (g.target > 0) _Objective(game: g),
        if (g.finishedAt == null) _GameToolbar(game: g),
        LayoutBuilder(
          builder: (context, c) => c.maxWidth > 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: board),
                    const SizedBox(width: 24),
                    SizedBox(width: 280, child: timer(context)),
                  ],
                )
              : Column(
                  children: [
                    board,
                    const SizedBox(height: 24),
                    if (g.finishedAt == null) timer(context),
                  ],
                ),
        ),
        if (g.finishedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: FilledButton(
              onPressed: () => context.push(
                GameSetupRequest.path,
                extra: GameSetupRequest(
                  names: g.players.map((p) => p.name).toList(),
                ),
              ),
              child: Text(tr(context, 'La revanche', 'Play again')),
            ),
          ),
      ],
    );
  }
}

class _NoGame extends StatelessWidget {
  const _NoGame();
  @override
  Widget build(BuildContext context) => EmptyPanel(
    title: tr(context, 'Votre table vous attend', 'Your table awaits'),
    message: tr(
      context,
      'Créez une partie pour compter les points et suivre les tours.',
      'Create a game to track scores and turns.',
    ),
    action: FilledButton(
      onPressed: () => context.push(GameSetupRequest.path),
      child: Text(tr(context, 'Créer une partie', 'Create game')),
    ),
  );
}

class _Objective extends StatelessWidget {
  const _Objective({required this.game});
  final GameSession game;
  @override
  Widget build(BuildContext context) {
    final g = game;
    final team = g.players.fold<double>(0, (sum, p) => sum + g.score(p.id));
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DeckPanel(
        highlight: g.objectiveReached,
        padding: 16,
        child: Text(
          '${g.objectiveReached ? '✓ ' : ''}${tr(context, 'Objectif', 'Target')} : ${numberText(g.target)}${g.cooperative ? ' / ${numberText(team)}' : ''}',
        ),
      ),
    );
  }
}

class _GameToolbar extends StatelessWidget {
  const _GameToolbar({required this.game});
  final GameSession game;

  Future<void> _finish(BuildContext context) async {
    final controller = context.read<GameCubit>();
    if (await confirm(
      context,
      tr(context, 'Terminer la partie ?', 'Finish game?'),
      tr(
        context,
        'Les scores seront conservés dans votre historique.',
        'Scores will be kept in your history.',
      ),
    )) {
      await controller.finish();
      if (context.mounted) context.go('/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameCubit>();
    final reverse = context.select<GameCubit, bool>((c) => c.state.reverse);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: controller.nextRound,
            icon: const DeckIcon(Icons.skip_next_outlined, size: 18),
            label: Text(tr(context, 'Manche suivante', 'Next round')),
          ),
          const SizedBox(width: 8),
          MenuAnchor(
            builder: (context, menu, _) => IconButton(
              tooltip: tr(context, 'Plus d’actions', 'More actions'),
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: const DeckIcon(Icons.more_horiz),
            ),
            menuChildren: [
              MenuItemButton(
                leadingIcon: DeckIcon(
                  reverse ? Icons.rotate_left : Icons.rotate_right,
                  size: 18,
                ),
                onPressed: controller.reverseTurnOrder,
                child: Text(tr(context, 'Sens de rotation', 'Turn direction')),
              ),
              if (game.pack != null)
                MenuItemButton(
                  leadingIcon: const DeckIcon(
                    Icons.menu_book_outlined,
                    size: 18,
                  ),
                  onPressed: () =>
                      context.push('/pack/${game.pack!.id}?session=1'),
                  child: Text(
                    tr(
                      context,
                      'Outils et règles du jeu',
                      'Game tools and rules',
                    ),
                  ),
                ),
              MenuItemButton(
                leadingIcon: const DeckIcon(Icons.ios_share_outlined, size: 18),
                onPressed: () => FileTransfer.shareText(
                  game.export(),
                  'partie-${game.id}.json',
                ),
                child: Text(tr(context, 'Exporter', 'Export')),
              ),
              MenuItemButton(
                leadingIcon: const DeckIcon(Icons.flag_outlined, size: 18),
                onPressed: () => _finish(context),
                child: Text(tr(context, 'Terminer', 'Finish')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
