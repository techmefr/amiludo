import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_add_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_look_sheet.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class Dice3dPanel extends StatelessWidget {
  const Dice3dPanel({
    super.key,
    required this.session,
    required this.stage,
    required this.skin,
    required this.table,
    required this.onConfigure,
    required this.onThrow,
    required this.onSkin,
    required this.onTable,
  });
  final DiceTraySession session;
  final Widget stage;
  final String skin, table;
  final ValueChanged<DiceTraySettings> onConfigure;
  final VoidCallback onThrow;
  final ValueChanged<String> onSkin, onTable;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final empty = session.settings.dice.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: () =>
                  showDiceAddSheet(context, session.settings, onConfigure),
              icon: const Icon(Icons.add),
              label: Text(l.diceTrayAddDie),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                l.diceTrayCount(session.settings.dice.length),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton.filledTonal(
              tooltip: l.diceLook,
              onPressed: () => showDiceLookSheet(
                context,
                skin: skin,
                table: table,
                onSkin: onSkin,
                onTable: onTable,
              ),
              icon: const Icon(Icons.palette_outlined),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        stage,
        const SizedBox(height: Space.md),
        SizedBox(
          height: Targets.minimum + Space.md,
          child: FilledButton.icon(
            onPressed: empty ? null : onThrow,
            icon: const DeckIcon(Icons.casino_outlined),
            label: Text(l.diceTrayThrow),
          ),
        ),
        const SizedBox(height: Space.md),
        Semantics(
          liveRegion: true,
          child: Column(
            children: [
              Text(
                session.thrown ? '${session.total}' : '–',
                style: theme.textTheme.displayMedium,
              ),
              if (session.thrown)
                Text(
                  [
                    for (var i = 0; i < session.values.length; i++)
                      session.settings.dice[i].faceLabel(session.values[i]),
                  ].join(' · '),
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
