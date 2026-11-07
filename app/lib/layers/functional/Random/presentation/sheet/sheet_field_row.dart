import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetFieldRow extends StatelessWidget {
  const SheetFieldRow({
    super.key,
    required this.field,
    required this.label,
    required this.values,
    required this.locked,
    required this.onReroll,
    required this.onLock,
    required this.onEdit,
  });

  final SheetField field;
  final String label;
  final List<String> values;
  final bool locked;
  final VoidCallback onReroll, onLock, onEdit;

  static const _target = BoxConstraints(
    minWidth: Targets.minimum,
    minHeight: Targets.minimum,
  );

  Widget _action(String key, String tip, IconData icon, VoidCallback? tap) =>
      IconButton(
        key: ValueKey('sheet-$key-${field.id}'),
        tooltip: tip,
        constraints: _target,
        onPressed: tap,
        icon: DeckIcon(icon),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelLarge),
                const SizedBox(height: Space.xs),
                if (values.isEmpty)
                  Text(
                    l10n.sheetEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final v in values) Text(v),
              ],
            ),
          ),
          _action(
            'reroll',
            l10n.sheetReroll,
            Icons.casino_outlined,
            locked ? null : onReroll,
          ),
          _action(
            'lock',
            locked ? l10n.sheetUnlock : l10n.sheetLock,
            locked ? Icons.lock : Icons.lock_open_outlined,
            onLock,
          ),
          _action('edit', l10n.sheetEdit, Icons.edit_outlined, onEdit),
        ],
      ),
    );
  }
}
