import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_style.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class HudBar extends StatelessWidget {
  const HudBar({super.key, required this.value, required this.label});
  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).extension<DeckStyle>()!;
    final shown = value.clamp(0.0, 1.0);
    return Semantics(
      label: label,
      value: '${(shown * 100).round()}%',
      excludeSemantics: true,
      child: Container(
        height: Space.xl,
        decoration: ShapeDecoration(
          color: scheme.surface,
          shape: style.border(scheme.primary),
          shadows: style.glow == null
              ? null
              : [BoxShadow(color: style.glow!, blurRadius: Space.sm)],
        ),
        padding: EdgeInsets.all(style.borderWidth),
        child: ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.centerLeft,
            duration: Motion.of(context, Motion.base),
            curve: Motion.curve,
            child: AnimatedFractionallySizedBox(
              widthFactor: shown,
              heightFactor: 1,
              duration: Motion.of(context, Motion.base),
              curve: Motion.curve,
              child: ColoredBox(color: scheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
