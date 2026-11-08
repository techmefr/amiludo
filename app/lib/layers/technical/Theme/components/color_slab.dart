import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const slabInk = Color(0xffffffff);

class ColorSlab extends StatelessWidget {
  const ColorSlab({
    super.key,
    required this.color,
    required this.child,
    this.glow,
  });
  final Color color;
  final Color? glow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(color, const Color(0xffffffff), .18)!;
    final deep = Color.lerp(color, const Color(0xff000000), .28)!;
    return AnimatedContainer(
      duration: Motion.of(context, Motion.base),
      curve: Motion.curve,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, color, deep],
          stops: const [0, .45, 1],
        ),
        border: Border.all(
          color: const Color(0xffffffff).withValues(alpha: .22),
          width: Hairline.width * 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (glow ?? deep).withValues(alpha: glow == null ? .45 : .8),
            blurRadius: glow == null ? Space.lg : Space.xxl,
            spreadRadius: glow == null ? 0 : Space.xs,
            offset: Offset(0, glow == null ? Space.sm : 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: Space.xxl,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33ffffff), Color(0x00ffffff)],
                    ),
                  ),
                ),
              ),
            ),
            DefaultTextStyle.merge(
              style: const TextStyle(color: slabInk),
              child: IconTheme(
                data: const IconThemeData(color: slabInk),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
