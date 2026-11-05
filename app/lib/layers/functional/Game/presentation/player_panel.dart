import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/player_trackers.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class PlayerPanel extends StatelessWidget {
  const PlayerPanel({
    super.key,
    required this.game,
    required this.index,
    required this.category,
  });
  final GameSession game;
  final int index;
  final String category;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = game.players[index];
    final active = game.finishedAt == null;
    return DeckPanel(
      highlight: index == game.activeIndex,
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlayerName(player: player, turn: index == game.activeIndex),
          const SizedBox(height: 20),
          Text(
            numberText(game.score(player.id)),
            style: TextStyle(
              fontFamily: theme.extension<DeckStyle>()!.headingFont,
              fontSize: 64,
              height: 1.1,
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          Text(
            '${context.l10n.gameRound} ${game.round} : ${numberText(game.score(player.id, inRound: game.round))}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (active) _ScoreButtons(player: player, category: category),
          const SizedBox(height: 12),
          PlayerTrackers(
            player: player,
            statuses: game.pack?.statuses ?? const [],
            active: active,
          ),
        ],
      ),
    );
  }
}

class _PlayerName extends StatelessWidget {
  const _PlayerName({required this.player, required this.turn});
  final Player player;
  final bool turn;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Color(player.color),
          foregroundColor: const Color(0xff151515),
          child: Text(player.name.characters.first),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(player.name, style: theme.textTheme.titleMedium)),
        if (turn)
          Tooltip(
            message: context.l10n.gameActivePlayer,
            child: DeckIcon(
              Icons.play_arrow,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class _ScoreButtons extends StatelessWidget {
  const _ScoreButtons({required this.player, required this.category});
  final Player player;
  final String category;

  Future<void> _custom(BuildContext context) async {
    final controller = context.read<GameCubit>();
    final value = await textPrompt(
      context,
      '${context.l10n.gamePointsFor} ${player.name}',
      initial: '0',
      label: context.l10n.gamePositiveOrNegativeValue,
    );
    if (value == null) return;
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || !number.isFinite || number.abs() > 1000000000) {
      if (context.mounted) {
        notify(context, context.l10n.gameInvalidValue);
      }
      return;
    }
    await controller.score(player.id, number, category);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameCubit>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in [-1, 1, 5])
          SizedBox(
            width: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () =>
                  controller.score(player.id, value.toDouble(), category),
              child: Text('${value > 0 ? '+' : ''}$value'),
            ),
          ),
        IconButton(
          tooltip: context.l10n.gameCustomValue,
          onPressed: () => _custom(context),
          icon: const DeckIcon(Icons.edit_outlined),
        ),
      ],
    );
  }
}
