import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

Future<String?> showImportDialog(BuildContext context) =>
    showDialog<String>(context: context, builder: (_) => const _ImportDialog());

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.bestiaryImport),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 4,
        maxLines: 10,
        decoration: InputDecoration(labelText: l.bestiaryImportHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.bestiaryImport),
        ),
      ],
    );
  }
}
