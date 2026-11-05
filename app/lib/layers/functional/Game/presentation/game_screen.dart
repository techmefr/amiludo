import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/game_board.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/game_setup_request.dart';
import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.timer});
  final WidgetBuilder timer;

  String _subtitle(BuildContext context, GameSession g) {
    final rule = g.cooperative
        ? context.l10n.gameCooperative
        : g.lowestWins
        ? context.l10n.gameLowestScoreWins
        : context.l10n.gameHighestScoreWins;
    return '${g.players.length} ${context.l10n.gamePlayers} · ${context.l10n.gameRound} ${g.round} · $rule';
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
              ? context.l10n.gameActiveGameLocalData
              : context.l10n.gameCompletedGame,
          title: g.title,
          subtitle: _subtitle(context, g),
          action: g.finishedAt == null
              ? null
              : OutlinedButton(
                  onPressed: () =>
                      FileTransfer.shareText(g.export(), 'partie-${g.id}.json'),
                  child: Text(context.l10n.appearanceExport),
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
              child: Text(context.l10n.gamePlayAgain),
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
    title: context.l10n.gameYourTableAwaits,
    message: context.l10n.gameCreateAGameToTrack,
    action: FilledButton(
      onPressed: () => context.push(GameSetupRequest.path),
      child: Text(context.l10n.gameCreateGame),
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
          '${g.objectiveReached ? '✓ ' : ''}${context.l10n.gameTarget} : ${numberText(g.target)}${g.cooperative ? ' / ${numberText(team)}' : ''}',
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
      context.l10n.gameFinishGame,
      context.l10n.gameScoresWillBeKeptIn,
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
            label: Text(context.l10n.gameNextRound),
          ),
          const SizedBox(width: 8),
          MenuAnchor(
            builder: (context, menu, _) => IconButton(
              tooltip: context.l10n.gameMoreActions,
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
                child: Text(context.l10n.gameTurnDirection),
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
                    context.l10n.gameGameToolsAndRules,
                  ),
                ),
              MenuItemButton(
                leadingIcon: const DeckIcon(Icons.ios_share_outlined, size: 18),
                onPressed: () => FileTransfer.shareText(
                  game.export(),
                  'partie-${game.id}.json',
                ),
                child: Text(context.l10n.appearanceExport),
              ),
              MenuItemButton(
                leadingIcon: const DeckIcon(Icons.flag_outlined, size: 18),
                onPressed: () => _finish(context),
                child: Text(context.l10n.gameFinish),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
