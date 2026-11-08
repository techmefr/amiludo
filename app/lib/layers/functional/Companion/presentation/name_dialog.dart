import 'package:flutter/material.dart';

Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String label,
}) => showDialog<String>(
  context: context,
  builder: (_) => _NameDialog(title: title, label: label),
);

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.label});
  final String title, label;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: (value) => Navigator.pop(context, value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: Text(widget.title),
      ),
    ],
  );
}
