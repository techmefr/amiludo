import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_controls.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_summary.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_surface_picker.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class Dice2dPanel extends StatelessWidget {
  const Dice2dPanel({
    super.key,
    required this.session,
    required this.stage,
    required this.onConfigure,
    required this.onSurface,
    required this.onThrow,
    required this.onKeep,
  });
  final DiceTraySession session;
  final Widget stage;
  final ValueChanged<DiceTraySettings> onConfigure;
  final ValueChanged<String> onSurface;
  final VoidCallback onThrow;
  final ValueChanged<int> onKeep;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final empty = session.settings.dice.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DiceTrayControls(settings: session.settings, onChanged: onConfigure),
        const SizedBox(height: Space.md),
        TraySurfacePicker(
          value: SurfaceMaterial.parse(session.settings.surface).name,
          onChanged: onSurface,
        ),
        const SizedBox(height: Space.lg),
        Text(
          empty
              ? l.diceTrayEmpty
              : '${l.diceTrayShakeHint} ${l.diceTrayKeepHint}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: Space.md),
        stage,
        const SizedBox(height: Space.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: empty ? null : onThrow,
            icon: const DeckIcon(Icons.casino_outlined),
            label: Text(l.diceTrayThrow),
          ),
        ),
        const SizedBox(height: Space.md),
        DiceTraySummary(session: session, onTapDie: onKeep),
      ],
    );
  }
}
