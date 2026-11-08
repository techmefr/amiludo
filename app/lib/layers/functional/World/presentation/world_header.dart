import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/presentation/world_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

enum _MapAction { grid, export, import, delete }

class WorldHeader extends StatelessWidget {
  const WorldHeader({
    super.key,
    required this.atlas,
    required this.selected,
    required this.grid,
    required this.onSelect,
    required this.onNew,
    required this.onGrid,
    required this.onExport,
    required this.onImport,
    required this.onDelete,
    required this.onSearch,
  });
  final WorldAtlas atlas;
  final String selected;
  final bool grid;
  final ValueChanged<String> onSelect;
  final VoidCallback onNew, onGrid, onExport, onImport, onDelete, onSearch;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Space.sm),
            child: Row(
              children: [
                for (final m in atlas.maps)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.sm),
                    child: ChoiceChip(
                      label: Text(
                        '${m.name} · ${context.scaleLevelLabel(m.level)}',
                      ),
                      selected: m.id == selected,
                      onSelected: (_) => onSelect(m.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: l.worldSearch,
          onPressed: onSearch,
          icon: const DeckIcon(Icons.search),
        ),
        IconButton(
          tooltip: l.worldNewMap,
          onPressed: onNew,
          icon: const DeckIcon(Icons.add),
        ),
        PopupMenuButton<_MapAction>(
          tooltip: l.worldMapOptions,
          onSelected: (a) => switch (a) {
            _MapAction.grid => onGrid(),
            _MapAction.export => onExport(),
            _MapAction.import => onImport(),
            _MapAction.delete => onDelete(),
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _MapAction.grid,
              child: Text(grid ? l.worldGridOff : l.worldGridOn),
            ),
            PopupMenuItem(value: _MapAction.export, child: Text(l.worldExport)),
            PopupMenuItem(value: _MapAction.import, child: Text(l.worldImport)),
            PopupMenuItem(
              value: _MapAction.delete,
              child: Text(l.worldDeleteMap),
            ),
          ],
        ),
      ],
    );
  }
}
