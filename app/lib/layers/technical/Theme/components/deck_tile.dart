import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DeckTile extends StatefulWidget {
  const DeckTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  @override
  State<DeckTile> createState() => _DeckTileState();
}

class _DeckTileState extends State<DeckTile> {
  bool pressed = false;

  void setPressed(bool value) => setState(() => pressed = value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final style = theme.extension<DeckStyle>()!;
    return Semantics(
      button: true,
      selected: widget.selected,
      excludeSemantics: true,
      label: widget.subtitle == null
          ? widget.title
          : "${widget.title}. ${widget.subtitle}",
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressed ? .97 : 1,
        duration: Motion.of(context, Motion.fast),
        curve: Motion.curve,
        child: Material(
          color: widget.selected ? scheme.secondary : scheme.surface,
          shape: style.border(
            widget.selected ? scheme.primary : scheme.outline,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: setPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Targets.minimum),
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeckIcon(widget.icon, size: 28, color: scheme.primary),
                    const SizedBox(height: Space.md),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: Space.xs),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
