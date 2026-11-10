import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_arena.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_view_toggle.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
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
    this.fill = false,
    this.aim = Offset.zero,
    this.onFlick,
    this.onTapTable,
    this.onLongPressDie,
  });
  final DiceTraySession session;
  final int throwId, seed;
  final double power;
  final Tilt tilt;
  final TrayFeedback feedback;
  final bool solid, fill;
  final DieSkin skin;
  final TableTheme table;
  final ValueChanged<List<int>> onOutcome;
  final ValueChanged<int> onTapDie;
  final ValueChanged<bool> onView;
  final Offset aim;
  final void Function(double power, Offset aim)? onFlick;
  final VoidCallback? onTapTable;
  final ValueChanged<int>? onLongPressDie;

  @override
  Widget build(BuildContext context) => fill
      ? SizedBox.expand(child: buildTray(context))
      : LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final window = MediaQuery.sizeOf(context);
            final compactLandscape =
                window.width > window.height && window.height < 520;
            final wide = window.width >= 600;
            final heightFraction = compactLandscape ? .58 : (wide ? .56 : .44);
            final height = solid
                ? math.min(
                    width * .88,
                    (window.height * heightFraction).clamp(140.0, 760.0),
                  )
                : (window.height * (wide ? .5 : .42)).clamp(240.0, 640.0);
            return Center(
              child: SizedBox(
                width: solid ? math.min(width, height * 1.8) : width,
                height: height,
                child: buildTray(context),
              ),
            );
          },
        );

  Widget buildTray(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: DiceTraySurface(
          session: session,
          throwId: throwId,
          seed: seed,
          power: power,
          aim: aim,
          onFlick: onFlick,
          onTapTable: onTapTable,
          onLongPressDie: onLongPressDie,
          tilt: tilt,
          feedback: feedback,
          solid: solid,
          skin: skin,
          table: table,
          onOutcome: onOutcome,
          onTapDie: onTapDie,
        ),
      ),
      if (!fill)
        TopBarSlot(
          tabs: ToolTabs(
            label: context.l10n.diceTrayView,
            current: solid ? 1 : 0,
            onSelect: (i) => onView(i == 1),
            items: [
              ToolTab(id: '2d', label: context.l10n.diceTrayView2d),
              ToolTab(id: '3d', label: context.l10n.diceTrayView3d),
            ],
          ),
          fallback: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: DiceViewToggle(solid: solid, onChanged: onView),
            ),
          ),
        ),
    ],
  );
}
