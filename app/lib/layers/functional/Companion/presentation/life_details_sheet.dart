import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/life_match.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_controller.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<void> showLifeDetails(
  BuildContext context,
  LifeController controller,
  int index,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => _Details(controller: controller, index: index),
  ),
);

class _Details extends StatelessWidget {
  const _Details({required this.controller, required this.index});
  final LifeController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final players = controller.match.players;
    final player = players[index];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(player.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Space.md),
            _Row(
              label: l.lifePoison,
              value: '${player.poison} / $poisonLimit',
              onMinus: () => controller.poison(index, -1),
              onPlus: () => controller.poison(index, 1),
            ),
            _Row(
              label: l.lifeEnergy,
              value: '${player.energy}',
              onMinus: () => controller.energy(index, -1),
              onPlus: () => controller.energy(index, 1),
            ),
            const SizedBox(height: Space.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l.lifeCommander,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final (i, other) in players.indexed)
              if (i != index)
                _Row(
                  label: l.lifeFromPlayer(other.name),
                  value: '${player.commander[i] ?? 0} / $commanderLimit',
                  onMinus: () => controller.commander(index, i, -1),
                  onPlus: () => controller.commander(index, i, 1),
                ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label, value;
  final VoidCallback onMinus, onPlus;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Semantics(
      container: true,
      label: '$label $value',
      child: Row(
        children: [
          Expanded(child: ExcludeSemantics(child: Text(label))),
          IconButton(
            tooltip: '${l.counterDecrease} $label',
            onPressed: onMinus,
            icon: const DeckIcon(Icons.remove),
          ),
          SizedBox(
            width: Space.xxl * 2,
            child: ExcludeSemantics(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFeatures: Numerals.tabular,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: '${l.counterIncrease} $label',
            onPressed: onPlus,
            icon: const DeckIcon(Icons.add),
          ),
        ],
      ),
    );
  }
}
