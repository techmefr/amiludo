import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Theme/components/sandglass_painter.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

TextStyle sandNumerals(double size) => TextStyle(
  fontFamily: 'Rajdhani',
  fontSize: size,
  fontWeight: FontWeight.w600,
  letterSpacing: 2,
  height: 1,
  color: SandPalette.cream,
  fontFeatures: Numerals.tabular,
);

class _DustPainter extends CustomPainter {
  const _DustPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    final paint = Paint()..color = SandPalette.sand.withValues(alpha: .16);
    for (var i = 0; i < 48; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        .6 + random.nextDouble() * 1.4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => false;
}

class SandScene extends StatelessWidget {
  const SandScene({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [SandPalette.night, SandPalette.dusk, SandPalette.ember],
        stops: [0, .65, 1],
      ),
    ),
    child: Stack(
      children: [
        const Positioned.fill(
          child: ExcludeSemantics(child: CustomPaint(painter: _DustPainter())),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              onSurface: SandPalette.cream,
              primary: SandPalette.sand,
            ),
          ),
          child: child,
        ),
      ],
    ),
  );
}

class SandPill extends StatelessWidget {
  const SandPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.selected = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool filled, selected;

  @override
  Widget build(BuildContext context) {
    final solid = filled || selected;
    final fill = solid ? SandPalette.sand : Colors.transparent;
    final ink = solid ? SandPalette.night : SandPalette.cream;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onPressed != null,
      excludeSemantics: true,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? .45 : 1,
        child: Material(
          color: fill,
          shape: StadiumBorder(
            side: BorderSide(
              color: SandPalette.sand.withValues(alpha: .7),
              width: 1.5,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed == null
                ? null
                : () {
                    DeckHaptics.selection();
                    onPressed!();
                  },
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: Targets.minimum,
                minWidth: Targets.minimum,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.w700,
                      fontSize: TypeScale.subtitle,
                      letterSpacing: 1,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
