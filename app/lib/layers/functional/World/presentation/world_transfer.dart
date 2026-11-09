import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/text_input_dialog.dart';

void _say(BuildContext context, String message) =>
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));

Future<void> copyAtlas(BuildContext context, WorldAtlas atlas) async {
  final message = context.l10n.worldCopied;
  await Clipboard.setData(ClipboardData(text: atlas.export()));
  if (context.mounted) _say(context, message);
}

Future<WorldAtlas?> importAtlas(BuildContext context, WorldAtlas atlas) async {
  final l = context.l10n;
  final text = await showTextInputDialog(
    context,
    title: l.worldImport,
    label: l.worldImportHint,
    confirm: l.worldImport,
    multiline: true,
  );
  if (text == null || !context.mounted) return null;
  final result = atlas.import(text);
  if (result == null) {
    _say(context, l.worldImportFailed);
    return null;
  }
  _say(context, l.worldImported(result.count));
  return result.merged;
}
