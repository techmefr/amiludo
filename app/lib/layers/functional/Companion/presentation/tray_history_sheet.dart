import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';

String trayRollLine(DiceTraySession session, TrayRoll roll) {
  final dice = session.settings.dice;
  final faces = [
    for (var i = 0; i < roll.values.length && i < dice.length; i++)
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
        ListTile(dense: true, title: Text(trayRollLine(session, roll))),
    ],
  ),
);
