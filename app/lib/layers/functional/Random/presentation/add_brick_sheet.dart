import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';

Future<String?> chooseCompanion(
  BuildContext context,
  List<GameTemplate> templates,
) => showDeckSheet<String>(
  context: context,
  title: context.l10n.brickChooseCompanion,
  builder: (sheet) => templates.isEmpty
      ? Text(sheet.l10n.brickNoCompanion)
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final t in templates)
              ListTile(
                title: Text(t.name),
                onTap: () => Navigator.of(sheet).pop(t.id),
              ),
          ],
        ),
);
