import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/map_board.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_controller.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_palette_row.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/icon_catalog.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const mapBackClearance = 56.0;

IconData _toolIcon(MapTool tool) => switch (tool) {
  MapTool.move => Icons.touch_app_outlined,
  MapTool.pin => Icons.flag_outlined,
  MapTool.token => Icons.diamond_outlined,
  MapTool.line => Icons.edit_outlined,
  MapTool.zone => Icons.hexagon_outlined,
  MapTool.erase => Icons.delete_outline,
};

String _toolLabel(BuildContext context, MapTool tool) {
  final l = context.l10n;
  return switch (tool) {
    MapTool.move => l.mapToolMove,
    MapTool.pin => l.mapToolPin,
    MapTool.token => l.mapToolToken,
    MapTool.line => l.mapToolLine,
    MapTool.zone => l.mapToolZone,
    MapTool.erase => l.mapToolErase,
  };
}

class MapToolbar extends StatelessWidget {
  const MapToolbar({
    super.key,
    required this.controller,
    required this.onBackground,
    required this.onIcon,
  });
  final MapController controller;
  final ValueChanged<MapBackground> onBackground;
  final VoidCallback onIcon;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: mapBackClearance, right: Space.sm),
        child: Row(
          children: [
            for (final tool in MapTool.values)
              IconButton(
                tooltip: _toolLabel(context, tool),
                isSelected: controller.tool == tool,
                style: IconButton.styleFrom(
                  backgroundColor: controller.tool == tool
                      ? scheme.primaryContainer
                      : null,
                ),
                onPressed: () => controller.select(tool),
                icon: DeckIcon(_toolIcon(tool)),
              ),
            IconButton(
              tooltip: l.mapUndo,
              onPressed: controller.canUndo ? controller.undo : null,
              icon: const DeckIcon(Icons.undo),
            ),
            PopupMenuButton<MapBackground>(
              tooltip: l.mapBackground,
              icon: const DeckIcon(Icons.view_module_outlined),
              onSelected: onBackground,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: MapBackground.blank,
                  child: Text(l.mapBackgroundBlank),
                ),
                PopupMenuItem(
                  value: MapBackground.grid,
                  child: Text(l.mapBackgroundGrid),
                ),
                PopupMenuItem(
                  value: MapBackground.hex,
                  child: Text(l.mapBackgroundHex),
                ),
                PopupMenuItem(
                  value: MapBackground.image,
                  child: Text(l.mapBackgroundImage),
                ),
              ],
            ),
            const SizedBox(width: Space.sm),
            MapPaletteRow(
              selected: controller.color,
              onPick: controller.setColor,
            ),
            IconButton(
              tooltip: l.mapIcon,
              onPressed: onIcon,
              icon: CatalogIcon(controller.icon),
            ),
          ],
        ),
      ),
    );
  }
}
