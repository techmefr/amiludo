import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/game_art_3d.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class ToolShelfStyle {
  const ToolShelfStyle(this.icon, this.theme);
  final IconData icon;
  final ToolTheme theme;
}

const toolShelfStyles = {
  'time': ToolShelfStyle(
    Icons.timer_outlined,
    ToolTheme(accent: Color(0xff2F7D8C), texture: ToolTexture.glass),
  ),
  'chance': ToolShelfStyle(
    Icons.casino_outlined,
    ToolTheme(accent: Color(0xffC2410C), texture: ToolTexture.felt),
  ),
  'scores': ToolShelfStyle(
    Icons.emoji_events_outlined,
    ToolTheme(accent: Color(0xffB7791F), texture: ToolTexture.tactile),
  ),
  'cards': ToolShelfStyle(
    Icons.style_outlined,
    ToolTheme(accent: Color(0xffA3274B), texture: ToolTexture.deck),
  ),
  'rules': ToolShelfStyle(
    Icons.menu_book_outlined,
    ToolTheme(accent: Color(0xff8A5A2B), texture: ToolTexture.parchment),
  ),
  'votes': ToolShelfStyle(
    Icons.how_to_vote_outlined,
    ToolTheme(accent: Color(0xff2F5D8C), texture: ToolTexture.paper),
  ),
  'party': ToolShelfStyle(
    Icons.celebration_outlined,
    ToolTheme(accent: Color(0xffC2493D), texture: ToolTexture.deck),
  ),
  'ambience': ToolShelfStyle(
    Icons.graphic_eq,
    ToolTheme(accent: Color(0xff2F7D6F), texture: ToolTexture.glass),
  ),
  'map': ToolShelfStyle(
    Icons.flag_outlined,
    ToolTheme(accent: Color(0xff3F7D4E), texture: ToolTexture.paper),
  ),
  'story': ToolShelfStyle(
    Icons.auto_stories_outlined,
    ToolTheme(accent: Color(0xff7B4B94), texture: ToolTexture.parchment),
  ),
  'generators': ToolShelfStyle(
    Icons.lightbulb_outline,
    ToolTheme(accent: Color(0xff4F46E5), texture: ToolTexture.plain),
  ),
  'gm': ToolShelfStyle(
    Icons.shield_moon_outlined,
    ToolTheme(accent: Color(0xff6D28D9), texture: ToolTexture.frame),
  ),
  'characters': ToolShelfStyle(
    Icons.badge_outlined,
    ToolTheme(accent: Color(0xff9A3412), texture: ToolTexture.frame),
  ),
  'players': ToolShelfStyle(
    Icons.groups_outlined,
    ToolTheme(accent: Color(0xff1D6FB8), texture: ToolTexture.plain),
  ),
};

ToolShelfStyle styleOfShelf(String id) => toolShelfStyles[id] ?? _fallbackStyle;

const _fallbackStyle = ToolShelfStyle(
  Icons.extension_outlined,
  ToolTheme(accent: Color(0xff52606D)),
);

class ToolCategoryTile extends StatelessWidget {
  const ToolCategoryTile({
    super.key,
    required this.shelf,
    required this.onOpen,
  });
  final ToolShelf shelf;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final style = styleOfShelf(shelf.id);
    final tool = style.theme;
    final illustrated = gameArtworkAsset(shelf.id) != null;
    final surface = illustrated
        ? GameCardStyle.background(shelf.id)
        : tool.surface(context, mix: .24);
    final ink = illustrated
        ? GameCardStyle.foreground(surface)
        : tool.ink(surface);
    final text = Theme.of(context).textTheme;
    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          tool.signal();
          onOpen();
        },
        child: Stack(
          children: [
            ToolTextureLayer(texture: tool.texture, opacity: .1),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'shelf-${shelf.id}',
                    child: illustrated
                        ? SizedBox(
                            width: double.infinity,
                            child: GameArt3D(
                              kind: shelf.id,
                              height: 96,
                              alignment: Alignment.centerRight,
                            ),
                          )
                        : SizedBox(
                            height: 96,
                            child: DeckIcon(style.icon, size: 48, color: ink),
                          ),
                  ),
                  const SizedBox(height: Space.lg),
                  Text(
                    context.toolShelfLabel(shelf.id),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(color: ink),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    [for (final id in shelf.tools) context.toolTitle(id)]
                        .join(', '),
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
    );
  }
}
