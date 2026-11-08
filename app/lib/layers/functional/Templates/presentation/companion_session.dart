import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_brick_row.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

typedef BrickWidgetBuilder = Widget? Function(BuildContext, Brick);

double sessionTileHeight(TileSize size) => switch (size) {
  TileSize.small => 240,
  TileSize.medium => 380,
  TileSize.large => 560,
};

class CompanionSession extends StatelessWidget {
  const CompanionSession({super.key, required this.id, required this.builder});
  final String id;
  final BrickWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final template = context
        .watch<TemplatesCubit>()
        .state
        .templates
        .where((t) => t.id == id)
        .firstOrNull;
    if (template == null) {
      return FullPage(
        title: context.l10n.templatesPackNotFound,
        fallback: '/',
        child: Text(context.l10n.templatesThisPackIsNoLonger),
      );
    }
    return FullPage(
      title: template.name,
      fallback: '/',
      immersive: true,
      maxWidth: 1400,
      child: ResponsiveGrid(
        minimumWidth: 340,
        children: [
          for (final brick in template.bricks)
            _SessionTile(key: ValueKey(brick.id), brick: brick, builder: builder),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({super.key, required this.brick, required this.builder});
  final Brick brick;
  final BrickWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final tool = toolThemeFor(brick.toolId);
    final body = builder(context, brick);
    return SizedBox(
      height: sessionTileHeight(brick.size),
      child: Material(
        color: tool.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: body ??
            Center(
              child: FilledButton(
                onPressed: () => context.push('/tools/${brick.type}'),
                child: Text(brickTitle(context, brick)),
              ),
            ),
      ),
    );
  }
}
