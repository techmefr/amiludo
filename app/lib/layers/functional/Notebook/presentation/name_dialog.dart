import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String action,
  String? label,
  String? hint,
  String initial = '',
}) => showDialog<String>(
  context: context,
  builder: (_) => _NameDialog(
    title: title,
    action: action,
    label: label,
    hint: hint,
    initial: initial,
  ),
);

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.action,
    required this.initial,
    this.label,
    this.hint,
  });

  final String title, action, initial;
  final String? label, hint;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() => Navigator.pop(context, controller.text.trim());

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
      ),
      onSubmitted: (_) => submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.themeCancel),
      ),
      FilledButton(onPressed: submit, child: Text(widget.action)),
    ],
  );
}
