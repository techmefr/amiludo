import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tray_result.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_add_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_look_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_view_toggle.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_history_sheet.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_bottom_bar.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_result_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/physical_tool_layout.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';
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
    this.mode = TrayResultMode.sum,
    this.onMode,
    this.onClear,
    this.onFavorite,
    this.showShakeHint = false,
    this.fullscreen = false,
    this.onView,
    this.onMotionAccess,
  });
  final DiceTraySession session;
  final Widget stage;
  final bool showShakeHint, fullscreen;
  final ValueChanged<bool>? onView;
  final VoidCallback? onMotionAccess;
  final String skin, table;
  final ValueChanged<DiceTraySettings> onConfigure;
  final VoidCallback onThrow;
  final ValueChanged<String> onSkin, onTable;
  final TrayResultMode mode;
  final ValueChanged<TrayResultMode>? onMode;
  final VoidCallback? onClear;
  final ValueChanged<String>? onFavorite;

  void _add(BuildContext context) => showDiceAddSheet(
    context,
    session.settings,
    onConfigure,
    onFavorite: onFavorite,
  );

  void _configure(BuildContext context) {
    final l = context.l10n;
    showDeckSheet<void>(
      context: context,
      title: l.diceTrayConfigure,
      builder: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onView != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DiceViewToggle(
                solid: true,
                onChanged: (solid) {
                  if (solid) return;
                  Navigator.pop(sheet);
                  onView!(solid);
                },
              ),
            ),
          if (onMotionAccess != null)
            ListTile(
              leading: const Icon(Icons.vibration),
              title: Text(l.appearanceMotionSensors),
              onTap: () {
                onMotionAccess!();
                Navigator.pop(sheet);
              },
            ),
          if (session.history.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(l.diceTrayHistory),
              onTap: () => showTrayHistorySheet(context, session),
            ),
          DiceLookPicker(
            skin: skin,
            table: table,
            onSkin: onSkin,
            onTable: onTable,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!fullscreen) {
      return PhysicalToolLayout(stage: stage, controls: buildControls(context));
    }
    final l = context.l10n;
    return Column(
      children: [
        Expanded(child: stage),
        Padding(
          padding: const EdgeInsets.all(Space.sm),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _configure(context),
                icon: const Icon(Icons.tune),
                label: Text(l.diceTrayConfigure),
              ),
              FilledButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add),
                label: Text(l.diceTrayAddDie),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildControls(BuildContext context) {
    final l = context.l10n;
    final empty = session.settings.dice.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ToolPrimaryButton(
          onPressed: empty ? null : onThrow,
          icon: Icons.casino_outlined,
          label: l.diceTrayThrow,
        ),
        if (showShakeHint && !empty)
          Padding(
            padding: const EdgeInsets.only(top: Space.sm),
            child: Text(
              l.diceTrayShakeHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: Space.md),
        TrayResultView(session: session, mode: mode, onMode: onMode),
        TrayBottomBar(
          session: session,
          onAdd: () => _add(context),
          onClear: onClear,
          onLook: () => showDiceLookSheet(
            context,
            skin: skin,
            table: table,
            onSkin: onSkin,
            onTable: onTable,
          ),
        ),
      ],
    );
  }
}
