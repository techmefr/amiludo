import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_brick_row.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

typedef BrickWidgetBuilder = Widget? Function(BuildContext, Brick);

class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.brick,
    required this.builder,
    this.frozen = false,
    this.onOpen,
  });
  final VoidCallback? onOpen;
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
          ? Center(
              child: _Caption(brick: brick, ink: ink, large: true),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.lg,
                    Space.md,
                    Space.lg,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Caption(brick: brick, ink: ink),
                      ),
                      if (onOpen != null)
                        IconButton(
                          tooltip: context.l10n.sessionFullscreen,
                          constraints: const BoxConstraints.tightFor(
                            width: Targets.minimum + Space.xs,
                            height: Targets.minimum + Space.xs,
                          ),
                          color: ink,
                          onPressed: onOpen,
                          icon: const DeckIcon(Icons.open_in_full),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      body ??
                      Center(
                        child: FilledButton(
                          onPressed: () => context.push('/tools/${brick.type}'),
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
