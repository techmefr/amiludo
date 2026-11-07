import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class SheetEditDialog extends StatefulWidget {
  const SheetEditDialog({
    super.key,
    required this.field,
    required this.label,
    required this.initial,
    required this.onSubmit,
  });

  final SheetField field;
  final String label;
  final List<String> initial;
  final bool Function(List<String> values) onSubmit;

  @override
  State<SheetEditDialog> createState() => _SheetEditDialogState();
}

class _SheetEditDialogState extends State<SheetEditDialog> {
  late final controller = TextEditingController(
    text: widget.initial.join('\n'),
  );
  bool invalid = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final values = widget.field.isList
        ? controller.text.split('\n')
        : [controller.text];
    if (widget.onSubmit(values)) {
      Navigator.pop(context);
    } else {
      setState(() => invalid = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final field = widget.field;
    final material = MaterialLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.label),
      content: TextField(
        key: const ValueKey('sheet-edit-input'),
        controller: controller,
        autofocus: true,
        minLines: 1,
        maxLines: field.isList ? 6 : 3,
        decoration: InputDecoration(
          helperText: field.isList ? l10n.sheetEditHint : null,
          errorText: invalid
              ? l10n.sheetEditInvalid(field.min, field.max)
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(material.cancelButtonLabel),
        ),
        FilledButton(
          key: const ValueKey('sheet-edit-save'),
          onPressed: submit,
          child: Text(material.okButtonLabel),
        ),
      ],
    );
  }
}
