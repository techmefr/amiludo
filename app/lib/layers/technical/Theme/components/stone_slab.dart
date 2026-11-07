import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class StonePalette {
  const StonePalette._();
  static const night = Color(0xff14110f);
  static const stone = Color(0xff24201c);
  static const edge = Color(0xff3a332b);
  static const cream = Color(0xffede3d1);
  static const ember = Color(0xffe8743b);
  static const danger = Color(0xffc8372d);
  static const heal = Color(0xff6fa36b);
  static const gold = Color(0xffc9a45c);
}

TextStyle stoneNumerals(double size) => TextStyle(
  fontFamily: 'ChakraPetch',
  fontSize: size,
  fontWeight: FontWeight.w700,
  height: 1.05,
  color: StonePalette.cream,
  fontFeatures: Numerals.tabular,
  shadows: const [
    Shadow(color: Color(0xff000000), offset: Offset(0, -1.5)),
    Shadow(color: Color(0x33ffffff), offset: Offset(0, 1.5)),
  ],
);

class StoneSlab extends StatelessWidget {
  const StoneSlab({
    super.key,
    required this.child,
    required this.accent,
    this.halo,
  });
  final Widget child;
  final Color accent;
  final Color? halo;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: Motion.of(context, Motion.base),
    decoration: BoxDecoration(
      color: StonePalette.stone,
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(color: StonePalette.edge, width: 2),
      boxShadow: [
        BoxShadow(
          color: (halo ?? const Color(0x66000000)).withValues(
            alpha: halo == null ? .4 : .55,
          ),
          blurRadius: halo == null ? Space.md : Space.xxl,
          spreadRadius: halo == null ? 0 : Space.xs,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ToolTexturePainter(
                  ToolTexture.tactile,
                  Color(0x0fede3d1),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: Space.xl,
            right: Space.xl,
            height: Space.xs,
            child: ColoredBox(color: accent),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                onSurface: StonePalette.cream,
                primary: StonePalette.gold,
              ),
              iconTheme: const IconThemeData(color: StonePalette.cream),
            ),
            child: child,
          ),
        ],
      ),
    ),
  );
}
