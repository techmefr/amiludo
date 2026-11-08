import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SwitcherItem {
  const SwitcherItem({
    required this.id,
    required this.label,
    required this.icon,
    this.color,
  });
  final String id, label;
  final IconData icon;
  final Color? color;
}

class CompanionButton extends StatelessWidget {
  const CompanionButton({
    super.key,
    required this.items,
    required this.current,
    required this.onSelect,
    required this.tooltip,
    required this.gridLabel,
    required this.onGrid,
  });
  final List<SwitcherItem> items;
  final int current;
  final ValueChanged<int> onSelect;
  final String tooltip, gridLabel;
  final VoidCallback onGrid;

  Future<void> _open(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => ToolSwitcherSheet(
      items: items,
      current: current,
      gridLabel: gridLabel,
      onSelect: (i) {
        Navigator.of(sheet).pop();
        onSelect(i);
      },
      onGrid: () {
        Navigator.of(sheet).pop();
        onGrid();
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(Targets.minimum + Space.xs),
        backgroundColor: scheme.surface.withValues(alpha: .55),
        foregroundColor: scheme.onSurfaceVariant,
      ),
      onPressed: () => _open(context),
      icon: const DeckIcon(Icons.apps_rounded),
    );
  }
}

class ToolSwitcherSheet extends StatelessWidget {
  const ToolSwitcherSheet({
    super.key,
    required this.items,
    required this.current,
    required this.gridLabel,
    required this.onSelect,
    required this.onGrid,
  });
  final List<SwitcherItem> items;
  final int current;
  final String gridLabel;
  final ValueChanged<int> onSelect;
  final VoidCallback onGrid;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
        child: Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++)
              Semantics(
                button: true,
                selected: i == current,
                label: items[i].label,
                child: ExcludeSemantics(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(Radii.lg),
                    onTap: () => onSelect(i),
                    child: Container(
                      width: 96,
                      constraints: const BoxConstraints(
                        minHeight: Targets.minimum + Space.xl,
                      ),
                      padding: const EdgeInsets.all(Space.sm),
                      decoration: BoxDecoration(
                        color: i == current
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(Radii.lg),
                        border: i == current
                            ? Border.all(color: scheme.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DeckIcon(items[i].icon, color: items[i].color),
                          const SizedBox(height: Space.xs),
                          Text(
                            items[i].label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: onGrid,
              icon: const DeckIcon(Icons.grid_view_rounded),
              label: Text(gridLabel),
            ),
          ],
        ),
      ),
    );
  }
}
