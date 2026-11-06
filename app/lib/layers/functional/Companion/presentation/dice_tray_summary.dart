import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_surface.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DiceTraySummary extends StatelessWidget {
  const DiceTraySummary({
    super.key,
    required this.session,
    required this.onTapDie,
  });
  final DiceTraySession session;
  final ValueChanged<int> onTapDie;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (session.kept.isNotEmpty) ...[
          Text(l.diceTrayKept, style: theme.textTheme.labelSmall),
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final i in session.kept.toList()..sort())
                GestureDetector(
                  onTap: () => onTapDie(i),
                  child: DieFace(
                    spec: session.settings.dice[i],
                    value: session.values[i],
                    kept: true,
                    size: Targets.minimum,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.md),
        ],
        Semantics(
          liveRegion: true,
          child: Text(
            '${l.diceTrayTotal} ${session.total}',
            style: theme.textTheme.headlineMedium,
          ),
        ),
        if (session.history.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          Text(l.diceTrayHistory, style: theme.textTheme.labelSmall),
          for (final roll in session.history.take(5))
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Text(_line(roll)),
            ),
        ],
      ],
    );
  }

  String _line(TrayRoll roll) {
    final dice = session.settings.dice;
    final faces = [
      for (var i = 0; i < roll.values.length && i < dice.length; i++)
        dice[i].faceLabel(roll.values[i]),
    ];
    return '${faces.join(' · ')} = ${roll.total}';
  }
}
