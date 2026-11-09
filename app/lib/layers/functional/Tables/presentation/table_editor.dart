import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Tables/domain/entities/roll_table.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<RollTable?> showTableEditor(
  BuildContext context, {
  RollTable? table,
  VoidCallback? onDelete,
}) => showModalBottomSheet<RollTable>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => TableEditor(table: table, onDelete: onDelete),
);

class TableEditor extends StatefulWidget {
  const TableEditor({super.key, this.table, this.onDelete});
  final RollTable? table;
  final VoidCallback? onDelete;

  @override
  State<TableEditor> createState() => _TableEditorState();
}

class _TableEditorState extends State<TableEditor> {
  late final name = TextEditingController(text: widget.table?.name);
  late final entries = TextEditingController(text: widget.table?.text);

  @override
  void dispose() {
    name.dispose();
    entries.dispose();
    super.dispose();
  }

  void _save() {
    final clean = name.text.trim();
    if (clean.isEmpty) return;
    Navigator.pop(
      context,
      RollTable.fromText(
        widget.table?.id ?? newTableId(),
        clean,
        entries.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: l.gmtablesName),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: entries,
              minLines: 6,
              maxLines: 16,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: l.gmtablesEntries),
            ),
            const SizedBox(height: Space.lg),
            FilledButton(onPressed: _save, child: Text(l.gmtablesSave)),
            if (widget.onDelete != null)
              TextButton(
                onPressed: () {
                  widget.onDelete!();
                  Navigator.pop(context);
                },
                child: Text(l.gmtablesDelete),
              ),
          ],
        ),
      ),
    );
  }
}
