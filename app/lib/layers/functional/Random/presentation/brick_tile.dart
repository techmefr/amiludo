import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class BrickTile extends StatelessWidget {
  const BrickTile({
    super.key,
    required this.entry,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
    this.onAdd,
  });
  final BrickEntry entry;
  final bool favorite;
  final VoidCallback onFavorite, onOpen;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DeckPanel(
      padding: 20,
      color: toolSurface(context, entry.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: GameArt(tool: entry.id, height: 112)),
              IconButton(
                tooltip: l.randomFavorite,
                onPressed: onFavorite,
                icon: DeckIcon(
                  favorite ? Icons.star : Icons.star_outline,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.xl),
          InkWell(
            onTap: onOpen,
            child: Text(
              context.toolTitle(entry.id),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: Space.sm),
          Text(context.toolSubtitle(entry.id)),
          const SizedBox(height: Space.lg),
          const Spacer(),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              OutlinedButton(onPressed: onOpen, child: Text(l.workspaceOpen)),
              if (onAdd != null)
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const DeckIcon(Icons.add),
                  label: Text(l.brickAddToCompanion),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
