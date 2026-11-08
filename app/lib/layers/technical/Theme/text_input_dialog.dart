import 'package:flutter/material.dart';

Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirm,
  String initial = '',
  bool multiline = false,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextInputDialog(
    title: title,
    label: label,
    confirm: confirm,
    initial: initial,
    multiline: multiline,
  ),
);

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.confirm,
    required this.initial,
    required this.multiline,
  });
  final String title, label, confirm, initial;
  final bool multiline;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final controller = TextEditingController(text: widget.initial);

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
      minLines: widget.multiline ? 4 : 1,
      maxLines: widget.multiline ? 10 : 1,
      decoration: InputDecoration(labelText: widget.label),
      onSubmitted: widget.multiline
          ? null
          : (value) => Navigator.pop(context, value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: Text(widget.confirm),
      ),
    ],
  );
}
