import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Tables/domain/entities/roll_table.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class TableCard extends StatelessWidget {
  const TableCard({
    super.key,
    required this.table,
    required this.tool,
    required this.result,
    required this.onRoll,
    required this.onEdit,
  });
  final RollTable table;
  final ToolTheme tool;
  final String? result;
  final VoidCallback onRoll, onEdit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final text = Theme.of(context).textTheme;
    final empty = table.entries.isEmpty;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: tool.accent.withValues(alpha: .45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  table.name,
                  style: text.titleMedium?.copyWith(color: ink),
                ),
              ),
              Text(
                l.gmtablesCount(table.entries.length),
                style: text.bodySmall?.copyWith(color: ink),
              ),
              IconButton(
                tooltip: l.gmtablesEdit(table.name),
                onPressed: onEdit,
                icon: const DeckIcon(Icons.build_outlined),
              ),
            ],
          ),
          Semantics(
            liveRegion: true,
            child: AnimatedSwitcher(
              duration: tool.duration(context),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Container(
                key: ValueKey(result),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: Text(
                  result ?? (empty ? l.gmtablesNoEntries : ''),
                  style: text.titleLarge?.copyWith(color: ink),
                ),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: empty ? null : onRoll,
            icon: const DeckIcon(Icons.casino_outlined),
            label: Text(l.gmtablesRoll(table.name)),
          ),
        ],
      ),
    );
  }
}
