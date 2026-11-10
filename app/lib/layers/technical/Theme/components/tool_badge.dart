import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

String toolHeroTag(String id) => 'tool-$id';

class ToolBadge extends StatelessWidget {
  const ToolBadge({super.key, required this.id, this.size = Targets.minimum});
  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tool = toolThemeFor(id);
    final fill = tool.surface(context, mix: .22);
    return Hero(
      tag: toolHeroTag(id),
      child: ExcludeSemantics(
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.control),
          ),
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: DeckIcon(
                toolIcon(id),
                size: size / 2,
                color: tool.ink(fill),
                strokeWidth: 1.8 * tool.weight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ToolHeaderPill extends StatelessWidget {
  const ToolHeaderPill({super.key, required this.id, required this.onBack});
  final String id;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tool = toolThemeFor(id);
    final scheme = Theme.of(context).colorScheme;
    final fill = tool.header == ToolHeader.plain
        ? scheme.surface.withValues(alpha: .55)
        : tool.surface(context, mix: .22).withValues(alpha: .92);
    return Material(
      color: fill,
      shape: StadiumBorder(
        side: tool.header == ToolHeader.ribbon
            ? BorderSide(color: tool.ink(fill), width: 2)
            : BorderSide.none,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            color: scheme.onSurface,
            style: IconButton.styleFrom(
              minimumSize: const Size.square(Targets.minimum),
            ),
            onPressed: onBack,
            icon: const BackButtonIcon(),
          ),
          if (tool.header != ToolHeader.plain) ...[
            ToolBadge(id: id, size: Targets.minimum - Space.sm),
            const SizedBox(width: Space.sm),
          ],
        ],
      ),
    );
  }
}
