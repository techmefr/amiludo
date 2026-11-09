import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _labelWidth = 150.0;
const _cellWidth = 92.0;

class SheetLine {
  const SheetLine({
    required this.label,
    this.fields,
    this.readings,
    this.emphasis = false,
  });
  final String label;
  final List<TextEditingController>? fields;
  final List<String>? readings;
  final bool emphasis;
}

class SheetGrid extends StatelessWidget {
  const SheetGrid({
    super.key,
    required this.players,
    required this.lines,
    required this.onChanged,
  });
  final List<String> players;
  final List<SheetLine> lines;
  final VoidCallback onChanged;

  Widget _cell(BuildContext context, SheetLine line, int player) {
    final theme = Theme.of(context).textTheme;
    final fields = line.fields;
    if (fields == null) {
      return Padding(
        padding: const EdgeInsets.all(Space.sm),
        child: Text(
          line.readings![player],
          textAlign: TextAlign.center,
          style: (line.emphasis ? theme.titleLarge : theme.bodyLarge)?.copyWith(
            fontFeatures: Numerals.tabular,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(Space.xs),
      child: Semantics(
        label: '${players[player]} ${line.label}',
        textField: true,
        child: TextField(
          controller: fields[player],
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[-0-9]'))],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Space.sm,
              vertical: Space.md,
            ),
          ),
          onChanged: (_) => onChanged(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: const FixedColumnWidth(_labelWidth),
          for (var p = 0; p < players.length; p++)
            p + 1: const FixedColumnWidth(_cellWidth),
        },
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              for (final name in players)
                Padding(
                  padding: const EdgeInsets.all(Space.sm),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleSmall,
                  ),
                ),
            ],
          ),
          for (final line in lines)
            TableRow(
              decoration: line.emphasis
                  ? BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  : null,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Space.sm),
                  child: Text(
                    line.label,
                    style: line.emphasis ? theme.titleMedium : theme.bodyMedium,
                  ),
                ),
                for (var p = 0; p < players.length; p++) _cell(context, line, p),
              ],
            ),
        ],
      ),
    );
  }
}
