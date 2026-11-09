import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_category_tile.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CategoryBanner extends StatelessWidget {
  const CategoryBanner({super.key, required this.shelf});
  final ToolShelf shelf;

  @override
  Widget build(BuildContext context) {
    final style = styleOfShelf(shelf.id);
    final tool = style.theme;
    final surface = tool.surface(context, mix: .3);
    final ink = tool.ink(surface);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xl),
      child: Material(
        borderRadius: BorderRadius.circular(Radii.lg),
        clipBehavior: Clip.antiAlias,
        color: surface,
        child: Stack(
          children: [
            ToolTextureLayer(texture: tool.texture, opacity: .12),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    onPressed: () => context.pop(),
                    icon: DeckIcon(Icons.arrow_back, color: ink),
                  ),
                  const SizedBox(width: Space.sm),
                  Hero(
                    tag: 'shelf-${shelf.id}',
                    child: DeckIcon(style.icon, size: 44, color: ink),
                  ),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Text(
                      context.toolShelfLabel(shelf.id),
                      style: text.headlineMedium?.copyWith(color: ink),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
