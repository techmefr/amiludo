import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/presentation/draw_tool.dart';
import 'package:amiludo/layers/functional/World/presentation/world_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class WorldToolbar extends StatelessWidget {
  const WorldToolbar({
    super.key,
    required this.tool,
    required this.brush,
    required this.onTool,
    required this.onBrush,
    required this.onUndo,
  });
  final DrawTool tool;
  final double brush;
  final ValueChanged<DrawTool> onTool;
  final ValueChanged<double> onBrush;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final sizeLabels = [l.worldSizeSmall, l.worldSizeMedium, l.worldSizeLarge];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Space.sm),
          child: Row(
            children: [
              for (final t in DrawTool.values)
                Padding(
                  padding: const EdgeInsets.only(right: Space.sm),
                  child: ChoiceChip(
                    avatar: DeckIcon(t.icon, size: 18),
                    label: Text(context.drawToolLabel(t)),
                    selected: tool == t,
                    onSelected: (_) => onTool(t),
                  ),
                ),
              IconButton(
                tooltip: l.worldUndo,
                onPressed: onUndo,
                icon: const Icon(Icons.undo),
              ),
            ],
          ),
        ),
        if (tool.kind?.isBrush ?? false)
          Padding(
            padding: const EdgeInsets.only(top: Space.xs, left: Space.sm),
            child: Wrap(
              spacing: Space.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l.worldBrushSize),
                for (final (i, size) in brushSizes.indexed)
                  ChoiceChip(
                    label: Text(sizeLabels[i]),
                    selected: brush == size,
                    onSelected: (_) => onBrush(size),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
