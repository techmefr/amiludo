import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tray_result.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_add_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_look_sheet.dart';
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
  });
  final DiceTraySession session;
  final Widget stage;
  final bool showShakeHint;
  final String skin, table;
  final ValueChanged<DiceTraySettings> onConfigure;
  final VoidCallback onThrow;
  final ValueChanged<String> onSkin, onTable;
  final TrayResultMode mode;
  final ValueChanged<TrayResultMode>? onMode;
  final VoidCallback? onClear;
  final ValueChanged<String>? onFavorite;

  @override
  Widget build(BuildContext context) =>
      PhysicalToolLayout(stage: stage, controls: buildControls(context));

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
          onAdd: () => showDiceAddSheet(
            context,
            session.settings,
            onConfigure,
            onFavorite: onFavorite,
          ),
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
