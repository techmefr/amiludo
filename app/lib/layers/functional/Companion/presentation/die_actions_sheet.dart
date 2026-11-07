import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_editor_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';

Future<void> openDieEditor(BuildContext context, DieDesign design) {
  final cubit = DieStudio.maybeOf(context);
  if (cubit == null) return Future.value();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          DieStudio(cubit: cubit, child: DieEditorScreen(initial: design)),
    ),
  );
}

Future<void> showDieActionsSheet(
  BuildContext context,
  DiceSpec spec, {
  required VoidCallback onRemove,
}) {
  final design = spec.design;
  final canEdit = design != null && DieStudio.maybeOf(context) != null;
  return showDeckSheet<void>(
    context: context,
    title: spec.name,
    builder: (sheet) {
      final l = sheet.l10n;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.diceEdit),
              onTap: () {
                Navigator.pop(sheet);
                openDieEditor(context, design!);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l.diceTrayRemoveDie),
            onTap: () {
              Navigator.pop(sheet);
              onRemove();
            },
          ),
        ],
      );
    },
  );
}
