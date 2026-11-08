import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

Future<String?> askBrickLabel(BuildContext context, String current) =>
    showDialog<String>(
      context: context,
      builder: (_) => _LabelDialog(current: current),
    );

class _LabelDialog extends StatefulWidget {
  const _LabelDialog({required this.current});
  final String current;

  @override
  State<_LabelDialog> createState() => _LabelDialogState();
}

class _LabelDialogState extends State<_LabelDialog> {
  late final TextEditingController text = TextEditingController(
    text: widget.current,
  );

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.brickSettings),
      content: TextField(
        controller: text,
        autofocus: true,
        maxLength: 40,
        decoration: InputDecoration(labelText: l.buildLabel),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.themeCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, text.text),
          child: Text(l.buildSave),
        ),
      ],
    );
  }
}
