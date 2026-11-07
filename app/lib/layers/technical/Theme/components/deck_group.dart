import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DeckGroup extends StatelessWidget {
  const DeckGroup({
    super.key,
    required this.children,
    this.header,
    this.footer,
  });
  final List<Widget> children;
  final String? header, footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget caption(String text, double top, double bottom) => Padding(
      padding: EdgeInsets.fromLTRB(Space.lg, top, Space.lg, bottom),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) caption(header!, 0, Space.sm),
        Material(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.group),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: Space.lg),
                children[i],
              ],
            ],
          ),
        ),
        if (footer != null) caption(footer!, Space.sm, 0),
      ],
    );
  }
}

class DeckGroupTile extends StatelessWidget {
  const DeckGroupTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      minTileHeight: 52,
      leading: icon == null ? null : DeckIcon(icon!, size: 24),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing:
          trailing ??
          (onTap == null
              ? null
              : DeckIcon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                )),
      onTap: onTap == null
          ? null
          : () {
              DeckHaptics.selection();
              onTap!();
            },
    );
  }
}
