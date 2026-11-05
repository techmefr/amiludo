import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Game/domain/entities/game.dart';
import 'package:amiludo/layers/functional/Game/presentation/cubit/game_cubit.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class PlayerTrackers extends StatelessWidget {
  const PlayerTrackers({
    super.key,
    required this.player,
    required this.statuses,
    required this.active,
  });
  final Player player;
  final List<String> statuses;
  final bool active;

  Future<void> _newCounter(BuildContext context) async {
    final controller = context.read<GameCubit>();
    final key = await textPrompt(
      context,
      context.l10n.templatesCounterName,
      initial: context.l10n.gameLives,
    );
    if (key == null || key.trim().isEmpty || !context.mounted) return;
    final value = await textPrompt(
      context,
      '${player.name} / $key',
      initial: numberText(player.resources[key] ?? 0),
    );
    final amount = double.tryParse(value?.replaceAll(',', '.') ?? '');
    if (amount == null || !amount.isFinite) {
      if (value != null && context.mounted) {
        notify(context, context.l10n.gameInvalidValue);
      }
      return;
    }
    await controller.setResource(player.id, key, amount);
  }

  @override
  Widget build(BuildContext context) {
    final known = {...statuses, ...player.statuses.keys};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in player.resources.entries)
          _Counter(player: player, name: e.key, value: e.value, active: active),
        if (known.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in known)
                  _StatusChip(
                    player: player,
                    status: s,
                    stacks: player.statuses[s] ?? 0,
                    active: active,
                  ),
              ],
            ),
          ),
        if (active)
          TextButton.icon(
            onPressed: () => _newCounter(context),
            icon: const DeckIcon(Icons.add, size: 16),
            label: Text(context.l10n.gameCounter),
          ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.player,
    required this.name,
    required this.value,
    required this.active,
  });
  final Player player;
  final String name;
  final double value;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameCubit>();
    return Row(
      children: [
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        if (active)
          IconButton(
            tooltip: '${context.l10n.gameRemove1From} $name',
            visualDensity: VisualDensity.compact,
            onPressed: () => controller.setResource(player.id, name, value - 1),
            icon: const DeckIcon(Icons.remove, size: 18),
          ),
        Text(
          numberText(value),
          style: const TextStyle(fontFamily: 'IBMPlexMono', fontSize: 18),
        ),
        if (active)
          IconButton(
            tooltip: '${context.l10n.gameAdd1To} $name',
            visualDensity: VisualDensity.compact,
            onPressed: () => controller.setResource(player.id, name, value + 1),
            icon: const DeckIcon(Icons.add, size: 18),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.player,
    required this.status,
    required this.stacks,
    required this.active,
  });
  final Player player;
  final String status;
  final int stacks;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameCubit>();
    return Tooltip(
      message: context.l10n.gameStackSTapToAdd(status, stacks),
      child: FilterChip(
        label: Text(stacks > 1 ? '$status ×$stacks' : status),
        selected: stacks > 0,
        showCheckmark: false,
        onSelected: active
            ? (_) => controller.setStatus(player.id, status, stacks + 1)
            : null,
        onDeleted: active && stacks > 0
            ? () => controller.setStatus(player.id, status, stacks - 1)
            : null,
        deleteIcon: const DeckIcon(Icons.remove, size: 14),
        deleteButtonTooltipMessage: context.l10n.gameRemoveOneStack(status),
      ),
    );
  }
}
