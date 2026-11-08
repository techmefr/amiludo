import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/functional/Library/presentation/game_cover.dart';
import 'package:amiludo/layers/functional/Library/presentation/shelf_game_fields.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class GameCards extends StatelessWidget {
  const GameCards({super.key, required this.games, required this.onOpen});

  final List<ShelfGame> games;
  final ValueChanged<ShelfGame> onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final columns = (c.maxWidth / 190).floor().clamp(2, 6);
      final width = (c.maxWidth - (columns - 1) * Space.lg) / columns;
      return Wrap(
        spacing: Space.lg,
        runSpacing: Space.lg,
        children: [
          for (final game in games)
            SizedBox(
              width: width,
              child: GameCard(game: game, width: width, onOpen: onOpen),
            ),
        ],
      );
    },
  );
}

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.width,
    required this.onOpen,
  });

  final ShelfGame game;
  final double width;
  final ValueChanged<ShelfGame> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: game.name,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => onOpen(game),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameCover(game: game, size: width, rounded: false),
                Padding(
                  padding: const EdgeInsets.all(Space.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        '${game.minPlayers}-${game.maxPlayers} · ${game.minutes} min',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (game.status != 'owned') ...[
                        const SizedBox(height: Space.sm),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(shelfStatusLabel(context, game.status)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
