import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_arena.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_view_toggle.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TrayStage extends StatelessWidget {
  const TrayStage({
    super.key,
    required this.session,
    required this.throwId,
    required this.seed,
    required this.power,
    required this.tilt,
    required this.feedback,
    required this.solid,
    required this.skin,
    required this.table,
    required this.onOutcome,
    required this.onTapDie,
    required this.onView,
  });
  final DiceTraySession session;
  final int throwId, seed;
  final double power;
  final Tilt tilt;
  final TrayFeedback feedback;
  final bool solid;
  final DieSkin skin;
  final TableTheme table;
  final ValueChanged<List<int>> onOutcome;
  final ValueChanged<int> onTapDie;
  final ValueChanged<bool> onView;

  @override
  Widget build(BuildContext context) {
    final trayHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      240.0,
      520.0,
    );
    return SizedBox(
      height: trayHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: DiceTraySurface(
              session: session,
              throwId: throwId,
              seed: seed,
              power: power,
              tilt: tilt,
              feedback: feedback,
              solid: solid,
              skin: skin,
              table: table,
              onOutcome: onOutcome,
              onTapDie: onTapDie,
            ),
          ),
          Positioned(
            top: Space.sm,
            right: Space.sm,
            child: DiceViewToggle(solid: solid, onChanged: onView),
          ),
        ],
      ),
    );
  }
}
