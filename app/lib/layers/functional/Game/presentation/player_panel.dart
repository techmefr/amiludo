import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/functional/Game/presentation/player_trackers.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

const _quickValues = [5, 10, 20];

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
    final background = Color(player.color);
    final ink = readableOn(background);
    final turn = index == game.activeIndex;
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
        side: turn
            ? BorderSide(color: theme.colorScheme.accentInk, width: 3)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: IconTheme(
          data: IconThemeData(color: ink),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: ink),
            child: Column(
              children: [
                _Header(player: player, turn: turn),
                _ScoreRow(
                  game: game,
                  player: player,
                  category: category,
                  active: active,
                ),
                if (active) _QuickRow(player: player, category: category),
                PlayerTrackers(
                  player: player,
                  statuses: game.pack?.statuses ?? const [],
                  active: active,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.player, required this.turn});
  final Player player;
  final bool turn;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          player.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: DefaultTextStyle.of(context).style.color),
        ),
      ),
      if (turn)
        Tooltip(
          message: context.l10n.gameActivePlayer,
          child: const DeckIcon(Icons.play_arrow, size: 20),
        ),
    ],
  );
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.game,
    required this.player,
    required this.category,
    required this.active,
  });
  final GameSession game;
  final Player player;
  final String category;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<GameCubit>();
    return Row(
      children: [
        if (active)
          _Step(
            icon: Icons.remove,
            tooltip: '-1',
            onTap: () => controller.score(player.id, -1, category),
          ),
        Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: active
                    ? () => customScore(context, player, category)
                    : null,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    numberText(game.score(player.id)),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: DefaultTextStyle.of(context).style.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Text(
                '${context.l10n.gameRound} ${game.round} : ${numberText(game.score(player.id, inRound: game.round))}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: DefaultTextStyle.of(context).style.color,
                ),
              ),
            ],
          ),
        ),
        if (active)
          _Step(
            icon: Icons.add,
            tooltip: '+1',
            onTap: () => controller.score(player.id, 1, category),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    iconSize: 32,
    onPressed: onTap,
    icon: DeckIcon(icon, size: 32),
  );
}

class _QuickRow extends StatelessWidget {
  const _QuickRow({required this.player, required this.category});
  final Player player;
  final String category;
  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameCubit>();
    final ink = readableOn(Color(player.color));
    return Padding(
      padding: const EdgeInsets.only(top: Space.md, bottom: Space.sm),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: Space.sm,
        runSpacing: Space.sm,
        children: [
          for (final value in _quickValues)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                side: BorderSide(color: ink),
                minimumSize: const Size(56, 40),
              ),
              onPressed: () =>
                  controller.score(player.id, value.toDouble(), category),
              child: Text('+$value'),
            ),
          IconButton(
            tooltip: context.l10n.gameCustomValue,
            onPressed: () => customScore(context, player, category),
            icon: const DeckIcon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

Future<void> customScore(
  BuildContext context,
  Player player,
  String category,
) async {
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
