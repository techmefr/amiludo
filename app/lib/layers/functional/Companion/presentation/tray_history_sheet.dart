import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_face_marks.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';

String trayRollLine(DiceTraySession session, TrayRoll roll) {
  final dice = roll.dice.isEmpty ? session.settings.dice : roll.dice;
  final faces = [
    for (var i = 0; i < roll.values.length && i < dice.length; i++)
      if (roll.values[i] >= 1 && roll.values[i] <= dice[i].sides)
        dice[i].faceLabel(roll.values[i]),
  ];
  return '${faces.join(' · ')} = ${roll.total}';
}

Future<void> showTrayHistorySheet(
  BuildContext context,
  DiceTraySession session,
) => showDeckSheet<void>(
  context: context,
  title: context.l10n.diceTrayHistory,
  builder: (_) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final roll in session.history)
        ListTile(
          dense: true,
          title: Text(trayRollLine(session, roll)),
          subtitle: roll.dice.isEmpty
              ? null
              : TrayFaceMarks(
                  dice: roll.dice,
                  values: roll.values,
                  reader: DieStudio.maybeOf(context)?.image,
                ),
        ),
    ],
  ),
);
