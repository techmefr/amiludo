import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/game_art_3d.dart';
import 'package:flutter/semantics.dart';

import 'package:amiludo/layers/functional/Random/presentation/tool_preview.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_badge.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.id,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
    this.onAdd,
    this.onMoveEarlier,
    this.onMoveLater,
    this.width = 232,
  });
  final String id;
  final bool favorite;
  final VoidCallback onFavorite, onOpen;
  final VoidCallback? onAdd, onMoveEarlier, onMoveLater;
  final double? width;

  static const double previewHeight = 120;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tool = toolThemeFor(id);
    final illustrated = gameArtworkAsset(id) != null;
    final surface = illustrated
        ? GameCardStyle.background(id)
        : tool.surface(context);
    final ink = illustrated ? GameCardStyle.foreground(surface) : null;
    final text = theme.textTheme;
    return SizedBox(
      width: width,
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l.toolMoveEarlier): ?onMoveEarlier,
          CustomSemanticsAction(label: l.toolMoveLater): ?onMoveLater,
        },
        child: Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  tool.signal();
                  onOpen();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: toolHeroTag(id),
                      child: Stack(
                        children: [
                          ToolTextureLayer(texture: tool.texture, opacity: .09),
                          ToolPreview(id: id, height: previewHeight),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(Space.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.toolTitle(id),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(color: ink),
                          ),
                          const SizedBox(height: Space.xs),
                          Text(
                            context.toolSubtitle(id),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(color: ink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: Space.xs,
                right: Space.xs,
                child: Row(
                  children: [
                    if (onAdd != null)
                      IconButton(
                        tooltip: l.brickAddToCompanion,
                        color: ink,
                        onPressed: onAdd,
                        icon: const DeckIcon(Icons.add),
                      ),
                    IconButton(
                      tooltip: l.randomFavorite,
                      color: ink,
                      onPressed: onFavorite,
                      icon: DeckIcon(
                        favorite ? Icons.star : Icons.star_outline,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
