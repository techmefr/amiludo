import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<RuleSection?> editRuleSection(
  BuildContext context, {
  RuleSection? initial,
}) => showDialog<RuleSection>(
  context: context,
  builder: (_) => _RuleDialog(initial: initial),
);

class _RuleDialog extends StatefulWidget {
  const _RuleDialog({this.initial});
  final RuleSection? initial;

  @override
  State<_RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<_RuleDialog> {
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _body = TextEditingController(text: widget.initial?.body);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim(), body = _body.text.trim();
    if (title.isEmpty && body.isEmpty) return;
    Navigator.pop(context, RuleSection(title: title, body: body));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.initial == null ? l.rulesAddSection : l.rulesEditRule),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.rulesSectionTitle),
            ),
            const SizedBox(height: Space.lg),
            TextField(
              controller: _body,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(labelText: l.rulesSectionBody),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.themeCancel),
        ),
        FilledButton(onPressed: _save, child: Text(l.themeSave)),
      ],
    );
  }
}
