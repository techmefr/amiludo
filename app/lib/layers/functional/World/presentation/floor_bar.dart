import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

enum FloorAction { above, below, rename, remove }

class FloorBar extends StatelessWidget {
  const FloorBar({
    super.key,
    required this.floors,
    required this.selected,
    required this.onSelect,
    required this.onAction,
  });
  final List<MapFloor> floors;
  final String selected;
  final ValueChanged<String> onSelect;
  final ValueChanged<FloorAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: Space.sm),
            child: Row(
              children: [
                for (final f in floors)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.sm),
                    child: ChoiceChip(
                      label: Text(l.worldFloor(f.name)),
                      selected: f.id == selected,
                      onSelected: (_) => onSelect(f.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
        PopupMenuButton<FloorAction>(
          tooltip: l.worldFloorOptions,
          onSelected: onAction,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: FloorAction.above,
              child: Text(l.worldAddFloorAbove),
            ),
            PopupMenuItem(
              value: FloorAction.below,
              child: Text(l.worldAddFloorBelow),
            ),
            PopupMenuItem(
              value: FloorAction.rename,
              child: Text(l.worldRenameFloor),
            ),
            if (floors.length > 1)
              PopupMenuItem(
                value: FloorAction.remove,
                child: Text(l.worldDeleteFloor),
              ),
          ],
        ),
      ],
    );
  }
}
