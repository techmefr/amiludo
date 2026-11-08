import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_tile.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

double sessionTileHeight(TileSize size) => switch (size) {
  TileSize.small => 240,
  TileSize.medium => 380,
  TileSize.large => 560,
};

const double sessionColumnWidth = 340;

int sessionColumns(double width) =>
    ((width + Space.md) / (sessionColumnWidth + Space.md)).floor().clamp(1, 6);

double sessionTileWidth(double width, int columns, int span) {
  final column = (width - Space.md * (columns - 1)) / columns;
  final used = span > columns ? columns : span;
  return column * used + Space.md * (used - 1);
}

class SessionGrid extends StatelessWidget {
  const SessionGrid({
    super.key,
    required this.bricks,
    required this.builder,
    required this.arrange,
    required this.onMove,
  });
  final List<Brick> bricks;
  final BrickWidgetBuilder builder;
  final bool arrange;
  final void Function(int from, int to) onMove;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = sessionColumns(constraints.maxWidth);
      return Wrap(
        spacing: Space.md,
        runSpacing: Space.md,
        children: [
          for (var i = 0; i < bricks.length; i++)
            _slot(
              context,
              i,
              sessionTileWidth(constraints.maxWidth, columns, bricks[i].span),
            ),
        ],
      );
    },
  );

  Widget _slot(BuildContext context, int index, double width) {
    final brick = bricks[index];
    final tile = _Entrance(
      key: ValueKey(brick.id),
      delay: Motion.fast * (index > 6 ? 6 : index) ~/ 3,
      child: AnimatedScale(
        scale: arrange ? .97 : 1,
        duration: Motion.of(context, Motion.base),
        curve: Motion.spring,
        child: SizedBox(
          width: width,
          height: sessionTileHeight(brick.size),
          child: SessionTile(brick: brick, builder: builder, frozen: arrange),
        ),
      ),
    );
    if (!arrange) return tile;
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => d.data != index,
      onAcceptWithDetails: (d) => onMove(d.data, index),
      builder: (context, candidates, _) => Draggable<int>(
        data: index,
        feedback: SizedBox(
          width: width,
          height: sessionTileHeight(brick.size),
          child: Opacity(
            opacity: .85,
            child: SessionTile(brick: brick, builder: builder, frozen: true),
          ),
        ),
        childWhenDragging: Opacity(opacity: .3, child: tile),
        child: AnimatedScale(
          scale: candidates.isEmpty ? 1 : .96,
          duration: Motion.of(context, Motion.fast),
          child: tile,
        ),
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({super.key, required this.delay, required this.child});
  final Duration delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final total = Motion.of(context, Motion.slow + delay);
    if (total == Duration.zero) return child;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Motion.curve),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
      ),
      child: child,
    );
  }
}
