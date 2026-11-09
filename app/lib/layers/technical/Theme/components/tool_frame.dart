import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_background.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_presets.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

Color toolFrameBackground(ThemeData base, ToolTheme tool) => Color.lerp(
  base.scaffoldBackgroundColor,
  tool.accent,
  base.brightness == Brightness.dark ? .12 : .07,
)!;

class ToolFrame extends StatelessWidget {
  const ToolFrame({super.key, required this.id, required this.child});
  final String id;
  final Widget child;

  static const double _lift = Space.xl;

  Widget _entrance(ToolTheme tool, double t, Widget child) {
    final shown = t.clamp(0.0, 1.0);
    return Opacity(
      opacity: shown,
      child: switch (tool.motion) {
        ToolMotion.snap || ToolMotion.tumble => Transform.scale(
          scale: .94 + .06 * t,
          child: child,
        ),
        ToolMotion.flow => Transform.translate(
          offset: Offset(0, (1 - t) * _lift),
          child: child,
        ),
        ToolMotion.flip => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .001)
            ..rotateX((1 - t) * .35),
          child: child,
        ),
        ToolMotion.drift => child,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tool = toolThemeFor(id);
    final base = Theme.of(context);
    final background = toolFrameBackground(base, tool);
    final ink = tool.ink(background);
    final themed = base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: ink,
        onPrimary: readableOn(ink),
      ),
    );
    return Theme(
      data: themed,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AuraBackground(
              preset: AuraPresets.tool(
                id,
                base.extension<DeckStyle>()?.skin ?? 'clean',
              ),
              theme: themed,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: tool.duration(context),
            curve: tool.curve,
            builder: (context, t, _) => _entrance(tool, t, child),
          ),
          if (tool.texture != ToolTexture.plain)
            ToolTextureLayer(texture: tool.texture),
        ],
      ),
    );
  }
}
