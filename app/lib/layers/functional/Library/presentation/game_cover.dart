import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/shelf_game.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class GameCover extends StatelessWidget {
  const GameCover({
    super.key,
    required this.game,
    this.size = 96,
    this.rounded = true,
  });

  final ShelfGame game;
  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final color = Color(game.color);
    final ink = onColorFor(color, dark: const Color(0xff000000));
    final fallback = ColoredBox(
      color: color,
      child: Center(
        child: Text(
          game.name.characters.firstOrNull?.toUpperCase() ?? '',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(color: ink),
        ),
      ),
    );
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rounded ? 12 : 0),
        child: SizedBox(
          width: size,
          height: size,
          child: game.imageUrl.isEmpty
              ? fallback
              : Image.network(
                  game.imageUrl,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, sync) =>
                      AnimatedOpacity(
                        opacity: frame == null && !sync ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: child,
                      ),
                  errorBuilder: (context, error, stack) => fallback,
                ),
        ),
      ),
    );
  }
}
