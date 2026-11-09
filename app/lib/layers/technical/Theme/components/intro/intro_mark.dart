import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/intro/intro_timeline.dart';

const double introZoomFactor = 40;

class IntroMark extends StatelessWidget {
  const IntroMark({
    super.key,
    required this.animation,
    required this.size,
    required this.travel,
  });

  final Animation<double> animation;
  final double size;
  final double travel;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final fly = IntroTimeline.span(
          t,
          IntroTimeline.piecesStart,
          IntroTimeline.piecesEnd,
          IntroTimeline.expoOut,
        );
        final thump = math.sin(
          math.pi *
              IntroTimeline.span(
                t,
                IntroTimeline.piecesEnd,
                IntroTimeline.thumpEnd,
              ),
        );
        final zoom = IntroTimeline.span(
          t,
          IntroTimeline.zoomStart,
          IntroTimeline.zoomEnd,
          IntroTimeline.quartIn,
        );
        final fadeIn = IntroTimeline.span(
          t,
          IntroTimeline.piecesStart,
          IntroTimeline.piecesStart + 300,
        );
        final fadeOut =
            1 -
            IntroTimeline.span(
              t,
              IntroTimeline.zoomStart + 400,
              IntroTimeline.zoomEnd,
            );
        return Opacity(
          opacity: fadeIn * fadeOut,
          child: Transform.scale(
            scale: (1 + .06 * thump) * (1 + introZoomFactor * zoom),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _Piece(
                    upper: true,
                    offset: Offset(-travel, -travel) * (1 - fly),
                    size: size,
                  ),
                  _Piece(
                    upper: false,
                    offset: Offset(travel, travel) * (1 - fly),
                    size: size,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _Piece extends StatelessWidget {
  const _Piece({required this.upper, required this.offset, required this.size});

  final bool upper;
  final Offset offset;
  final double size;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: offset,
    child: ClipPath(
      clipper: _HalfClipper(upper),
      child: Image.asset(
        'assets/brand/amiludo-mark.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    ),
  );
}

class _HalfClipper extends CustomClipper<Path> {
  const _HalfClipper(this.upper);
  final bool upper;

  @override
  Path getClip(Size size) {
    final w = size.width, h = size.height;
    return upper
        ? (Path()
            ..moveTo(0, 0)
            ..lineTo(w + 1, 0)
            ..lineTo(0, h + 1)
            ..close())
        : (Path()
            ..moveTo(w, 0)
            ..lineTo(w, h)
            ..lineTo(0, h)
            ..close());
  }

  @override
  bool shouldReclip(_HalfClipper old) => old.upper != upper;
}
