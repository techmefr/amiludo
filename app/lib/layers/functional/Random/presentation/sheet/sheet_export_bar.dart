import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_export.dart';
import 'package:amiludo/layers/functional/Random/presentation/sheet/sheet_labels.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Network/link_share.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetExportBar extends StatelessWidget {
  const SheetExportBar({
    super.key,
    required this.sheet,
    this.onSave,
    this.saved = false,
  });
  final CharacterSheet sheet;
  final VoidCallback? onSave;
  final bool saved;

  String _text(BuildContext context) => SheetExport.text(
    sheet,
    sheetLabelMap(context.l10n),
    sheetStepNames(context.l10n),
  );

  Future<void> _copy(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.sheetCopied;
    await copyText(text);
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: Space.md,
      runSpacing: Space.sm,
      children: [
        OutlinedButton(
          key: const ValueKey('sheet-copy-text'),
          onPressed: () => _copy(context, _text(context)),
          child: Text(l10n.sheetCopyText),
        ),
        OutlinedButton(
          key: const ValueKey('sheet-copy-json'),
          onPressed: () => _copy(context, SheetExport.jsonText(sheet)),
          child: Text(l10n.sheetCopyJson),
        ),
        OutlinedButton(
          key: const ValueKey('sheet-share'),
          onPressed: () => shareLink(_text(context)),
          child: Text(l10n.sheetShare),
        ),
        if (onSave != null)
          FilledButton(
            key: const ValueKey('sheet-save'),
            onPressed: saved ? null : onSave,
            child: Text(saved ? l10n.sheetSaved : l10n.sheetSave),
          ),
      ],
    );
  }
}
