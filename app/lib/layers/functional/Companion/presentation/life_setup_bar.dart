import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/life_match.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_controller.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class LifeSetupBar extends StatelessWidget {
  const LifeSetupBar({super.key, required this.controller});
  final LifeController controller;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final match = controller.match;
    final compact = MediaQuery.sizeOf(context).height < 420;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Space.sm,
      children: [
        if (compact)
          IconButton(
            onPressed: controller.canUndo ? controller.undo : null,
            icon: const DeckIcon(Icons.undo),
            tooltip: l.gameUndo,
          )
        else
          TextButton.icon(
            onPressed: controller.canUndo ? controller.undo : null,
            icon: const DeckIcon(Icons.undo),
            label: Text(l.gameUndo),
          ),
        PopupMenuButton<int>(
          tooltip: l.lifePlayers,
          onSelected: controller.resize,
          itemBuilder: (_) => [
            for (var n = minLifePlayers; n <= maxLifePlayers; n++)
              CheckedPopupMenuItem(
                value: n,
                checked: n == match.players.length,
                child: Text('$n'),
              ),
          ],
          icon: compact ? const DeckIcon(Icons.groups_outlined) : null,
          child: compact
              ? null
              : _Label(
                  icon: Icons.groups_outlined,
                  text: '${l.lifePlayers} ${match.players.length}',
                ),
        ),
        PopupMenuButton<int>(
          tooltip: l.lifeStartingLife,
          onSelected: (value) => controller.restart(start: value),
          itemBuilder: (_) => [
            for (final life in lifeStarts)
              CheckedPopupMenuItem(
                value: life,
                checked: life == match.start,
                child: Text('$life'),
              ),
          ],
          icon: compact ? const DeckIcon(Icons.favorite_border) : null,
          child: compact
              ? null
              : _Label(
                  icon: Icons.favorite_border,
                  text: '${l.lifeStartingLife} ${match.start}',
                ),
        ),
        if (compact)
          IconButton(
            onPressed: () => controller.restart(),
            icon: const DeckIcon(Icons.restart_alt),
            tooltip: l.appearanceReset,
          )
        else
          TextButton.icon(
            onPressed: () => controller.restart(),
            icon: const DeckIcon(Icons.restart_alt),
            label: Text(l.appearanceReset),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: Targets.minimum),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DeckIcon(icon),
          const SizedBox(width: Space.sm),
          Flexible(child: Text(text)),
        ],
      ),
    ),
  );
}
