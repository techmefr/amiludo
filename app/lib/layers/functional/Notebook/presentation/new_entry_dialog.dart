import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/entry_kinds.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class EntryDraft {
  const EntryDraft(this.kind, this.name);
  final EntryKind kind;
  final String name;
}

Future<EntryDraft?> showNewEntryDialog(
  BuildContext context, {
  EntryKind initial = EntryKind.npc,
}) => showDialog<EntryDraft>(
  context: context,
  builder: (_) => _NewEntryDialog(initial: initial),
);

class _NewEntryDialog extends StatefulWidget {
  const _NewEntryDialog({required this.initial});
  final EntryKind initial;

  @override
  State<_NewEntryDialog> createState() => _NewEntryDialogState();
}

class _NewEntryDialogState extends State<_NewEntryDialog> {
  final name = TextEditingController();
  late EntryKind kind = widget.initial;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void submit() {
    final text = name.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, EntryDraft(kind, text));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.notebookNewEntry),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: InputDecoration(labelText: l.notebookEntryName),
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              children: [
                for (final k in EntryKind.values)
                  ChoiceChip(
                    avatar: Icon(entryIcon(k), size: Space.lg),
                    label: Text(context.kindLabel(k)),
                    selected: kind == k,
                    onSelected: (_) => setState(() => kind = k),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.themeCancel),
        ),
        FilledButton(onPressed: submit, child: Text(l.notebookCreate)),
      ],
    );
  }
}
