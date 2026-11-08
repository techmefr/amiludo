import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_brick_row.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

typedef BrickWidgetBuilder = Widget? Function(BuildContext, Brick);

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
    final tile = SizedBox(
      key: ValueKey(brick.id),
      width: width,
      height: sessionTileHeight(brick.size),
      child: SessionTile(brick: brick, builder: builder, frozen: arrange),
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

class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.brick,
    required this.builder,
    this.frozen = false,
  });
  final Brick brick;
  final BrickWidgetBuilder builder;
  final bool frozen;

  @override
  Widget build(BuildContext context) {
    final tool = toolThemeFor(brick.toolId);
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final body = frozen ? null : builder(context, brick);
    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: frozen
          ? Center(child: _Caption(brick: brick, ink: ink, large: true))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.lg,
                    Space.md,
                    Space.lg,
                    0,
                  ),
                  child: _Caption(brick: brick, ink: ink),
                ),
                Expanded(
                  child:
                      body ??
                      Center(
                        child: FilledButton(
                          onPressed: () =>
                              context.push('/tools/${brick.type}'),
                          child: Text(brickTitle(context, brick)),
                        ),
                      ),
                ),
              ],
            ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.brick, required this.ink, this.large = false});
  final Brick brick;
  final Color ink;
  final bool large;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: large ? MainAxisSize.min : MainAxisSize.max,
    children: [
      DeckIcon(toolIcon(brick.toolId), size: large ? 40 : 20, color: ink),
      const SizedBox(width: Space.sm),
      Flexible(
        child: Text(
          brickTitle(context, brick),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: large
              ? Theme.of(context).textTheme.titleLarge
              : Theme.of(context).textTheme.labelLarge,
        ),
      ),
    ],
  );
}
