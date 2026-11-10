import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/layout_tokens.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key, required this.children, this.maxWidth = 760});
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inset = Gutters.columnInsetOf(context, maxWidth);
    return Material(
      color: scheme.surface,
      elevation: Elevation.overlay,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: inset, vertical: Space.md),
          child: Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: Space.md),
                Expanded(child: children[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
