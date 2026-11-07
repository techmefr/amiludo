import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_style.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class BlurBar extends StatelessWidget {
  const BlurBar({super.key, required this.child, this.top = false});
  final Widget child;
  final bool top;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.extension<DeckStyle>()?.clean != true) return child;
    final line = BorderSide(color: theme.dividerColor, width: Hairline.width);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: Hairline.blur, sigmaY: Hairline.blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(
              alpha: Hairline.barOpacity,
            ),
            border: top ? Border(bottom: line) : Border(top: line),
          ),
          child: child,
        ),
      ),
    );
  }
}
