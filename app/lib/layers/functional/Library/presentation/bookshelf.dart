import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class Bookshelf extends StatelessWidget {
  const Bookshelf({super.key, required this.games, required this.onOpen});

  static const spineWidth = 58.0;
  static const spineGap = 6.0;

  final List<ShelfGame> games;
  final ValueChanged<ShelfGame> onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final perRow = ((c.maxWidth - 24) / (spineWidth + spineGap))
          .floor()
          .clamp(1, 40);
      final rows = [
        for (var i = 0; i < games.length; i += perRow)
          games.sublist(i, (i + perRow).clamp(0, games.length)),
      ];
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xff3b2a1e),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              for (final row in rows) _ShelfRow(games: row, onOpen: onOpen),
            ],
          ),
        ),
      );
    },
  );
}

class _ShelfRow extends StatelessWidget {
  const _ShelfRow({required this.games, required this.onOpen});

  final List<ShelfGame> games;
  final ValueChanged<ShelfGame> onOpen;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 190,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, game) in games.indexed)
              Padding(
                padding: const EdgeInsets.only(right: Bookshelf.spineGap),
                child: GameSpine(
                  game: game,
                  height: 150 + (game.name.length * 7 + i * 13) % 36,
                  onTap: () => onOpen(game),
                ),
              ),
          ],
        ),
      ),
      Container(
        height: 14,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffa8743f), Color(0xff6e4724)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),
      ),
    ],
  );
}

class GameSpine extends StatelessWidget {
  const GameSpine({
    super.key,
    required this.game,
    required this.height,
    required this.onTap,
  });

  final ShelfGame game;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(game.color);
    final ink = onColorFor(color, dark: Colors.black);
    return Semantics(
      button: true,
      label: game.name,
      child: Tooltip(
        message: game.name,
        child: Material(
          color: color,
          elevation: 3,
          borderRadius: BorderRadius.circular(3),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              width: Bookshelf.spineWidth,
              height: height,
              child: _SpineLabel(game: game, ink: ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpineLabel extends StatelessWidget {
  const _SpineLabel({required this.game, required this.ink});

  final ShelfGame game;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: Column(
        children: [
          Container(height: 6, color: ink.withValues(alpha: .25)),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(color: ink),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${game.minPlayers}-${game.maxPlayers}',
              style: theme.textTheme.labelSmall?.copyWith(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}
