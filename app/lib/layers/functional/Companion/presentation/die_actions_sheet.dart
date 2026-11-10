import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_editor_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';

Future<DieDesign?> openDieEditor(
  BuildContext context,
  DieDesign? design,
) async {
  final cubit = DieStudio.maybeOf(context);
  if (cubit == null) return null;
  DieDesign? saved;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DieStudio(
        cubit: cubit,
        child: DieEditorScreen(
          initial: design,
          onSaved: (value) => saved = value,
        ),
      ),
    ),
  );
  return saved;
}

Future<void> showDieActionsSheet(
  BuildContext context,
  DiceSpec spec, {
  required VoidCallback onRemove,
  VoidCallback? onEdit,
}) {
  return showDeckSheet<void>(
    context: context,
    title: spec.name,
    builder: (sheet) {
      final l = sheet.l10n;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.diceEdit),
              onTap: () {
                Navigator.pop(sheet);
                onEdit();
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
