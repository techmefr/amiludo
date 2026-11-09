import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

String brickTitle(BuildContext context, Brick brick) =>
    brick.label ?? context.toolTitle(brick.toolId);

class CompanionBrickRow extends StatelessWidget {
  const CompanionBrickRow({
    super.key,
    required this.brick,
    required this.onResize,
    required this.onSettings,
    required this.onRemove,
    this.onEarlier,
    this.onLater,
  });
  final Brick brick;
  final ValueChanged<TileSize> onResize;
  final VoidCallback onRemove, onSettings;
  final VoidCallback? onEarlier, onLater;

  String _size(BuildContext context, TileSize size) {
    final l = context.l10n;
    return switch (size) {
      TileSize.small => l.buildSizeSmall,
      TileSize.medium => l.buildSizeMedium,
      TileSize.large => l.buildSizeLarge,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tool = toolThemeFor(brick.toolId);
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l.toolMoveEarlier): ?onEarlier,
        CustomSemanticsAction(label: l.toolMoveLater): ?onLater,
      },
      child: Material(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Row(
            children: [
              DeckIcon(toolIcon(brick.toolId), size: 28, color: ink),
              const SizedBox(width: Space.md),
              Expanded(
                child: Text(
                  brickTitle(context, brick),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              PopupMenuButton<TileSize>(
                tooltip: _size(context, brick.size),
                initialValue: brick.size,
                onSelected: onResize,
                icon: const DeckIcon(Icons.view_module_outlined),
                itemBuilder: (_) => [
                  for (final size in TileSize.values)
                    PopupMenuItem(
                      value: size,
                      child: Text(_size(context, size)),
                    ),
                ],
              ),
              IconButton(
                tooltip: l.brickSettings,
                onPressed: onSettings,
                icon: const DeckIcon(Icons.tune),
              ),
              IconButton(
                tooltip: l.buildRemove,
                onPressed: onRemove,
                icon: const DeckIcon(Icons.delete_outline),
              ),
              const SizedBox(width: Space.lg),
            ],
          ),
        ),
      ),
    );
  }
}
