import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Tables/domain/entities/roll_table.dart';
import 'package:amiludo/layers/functional/Tables/presentation/table_card.dart';
import 'package:amiludo/layers/functional/Tables/presentation/table_editor.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class TablesTool extends StatefulWidget {
  const TablesTool({
    super.key,
    this.initial = const RollTables(),
    this.onChanged,
    this.random,
  });
  final RollTables initial;
  final ValueChanged<RollTables>? onChanged;
  final RandomTools? random;

  @override
  State<TablesTool> createState() => _TablesToolState();
}

class _TablesToolState extends State<TablesTool> {
  late RollTables tables = widget.initial;
  late final RandomTools random = widget.random ?? RandomTools();
  final tool = toolThemeFor('gmtables');
  final Map<String, String> results = {};

  void _commit(RollTables next) {
    setState(() => tables = next);
    widget.onChanged?.call(next);
  }

  void _roll(RollTable table) {
    tool.signal();
    final value = table.roll((count) => random.integer(0, count - 1));
    if (value != null) setState(() => results[table.id] = value);
  }

  Future<void> _edit([RollTable? table]) async {
    final saved = await showTableEditor(
      context,
      table: table,
      onDelete: table == null ? null : () => _commit(tables.remove(table.id)),
    );
    if (saved != null) _commit(tables.put(saved));
  }

  void _starter() {
    final l = context.l10n;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final starters = [
      (l.gmtablesStarterNames, l.gmtablesStarterNamesEntries),
      (l.gmtablesStarterTaverns, l.gmtablesStarterTavernsEntries),
      (l.gmtablesStarterLoot, l.gmtablesStarterLootEntries),
      (l.gmtablesStarterRumours, l.gmtablesStarterRumoursEntries),
      (l.gmtablesStarterEncounters, l.gmtablesStarterEncountersEntries),
    ];
    _commit(
      tables.addAll([
        for (final (i, (name, entries)) in starters.indexed)
          RollTable(
            id: '${stamp + i}',
            name: name,
            entries: entriesOf(entries.replaceAll('|', '\n')),
          ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton.icon(
              onPressed: _edit,
              icon: const DeckIcon(Icons.add),
              label: Text(l.gmtablesAdd),
            ),
            if (tables.isEmpty)
              OutlinedButton.icon(
                onPressed: _starter,
                icon: const DeckIcon(Icons.auto_stories_outlined),
                label: Text(l.gmtablesStarter),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        if (tables.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Text(l.gmtablesEmpty, textAlign: TextAlign.center),
          ),
        ResponsiveGrid(
          minimumWidth: 360,
          gap: Space.sm,
          children: [
            for (final t in tables.tables)
              TableCard(
                key: ValueKey(t.id),
                table: t,
                tool: tool,
                result: results[t.id],
                onRoll: () => _roll(t),
                onEdit: () => _edit(t),
              ),
          ],
        ),
      ],
    );
  }
}
