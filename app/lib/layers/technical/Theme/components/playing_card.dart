import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

abstract final class CardPalette {
  static const paper = Color(0xffFBF5E6);
  static const ink = Color(0xff1F1B16);
  static const red = Color(0xffB3261E);
  static const gold = Color(0xffC9A227);
  static const back = Color(0xff7A1F3D);
}

class PlayingCard extends StatelessWidget {
  const PlayingCard({
    super.key,
    this.rank,
    this.suit,
    this.label,
    this.red = false,
    this.faceDown = false,
    this.width = 160,
  });

  final String? rank, suit, label;
  final bool red, faceDown;
  final double width;

  double get height => width * 1.4;

  Widget _pips(TextStyle? base) => Stack(
    children: [
      Positioned(
        top: width * .06,
        left: width * .09,
        child: Column(
          children: [
            Text(rank!, style: base?.copyWith(fontSize: width * .17)),
            Text(suit!, style: base?.copyWith(fontSize: width * .15)),
          ],
        ),
      ),
      Center(child: Text(suit!, style: base?.copyWith(fontSize: width * .5))),
      Positioned(
        bottom: width * .06,
        right: width * .09,
        child: RotatedBox(
          quarterTurns: 2,
          child: Column(
            children: [
              Text(rank!, style: base?.copyWith(fontSize: width * .17)),
              Text(suit!, style: base?.copyWith(fontSize: width * .15)),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _written(TextStyle? base) => Padding(
    padding: EdgeInsets.all(width * .1),
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width * .8),
          child: Text(
            label ?? '',
            textAlign: TextAlign.center,
            style: base?.copyWith(fontSize: width * .13),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ink = red ? CardPalette.red : CardPalette.ink;
    final base = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: ink,
      fontWeight: FontWeight.w700,
      height: 1.05,
    );
    final front = suit != null && rank != null;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: faceDown ? CardPalette.back : CardPalette.paper,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: CardPalette.gold, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: Space.md,
              offset: Offset(0, Space.xs),
            ),
          ],
        ),
        child: faceDown
            ? ClipRRect(
                borderRadius: BorderRadius.circular(Radii.md),
                child: CustomPaint(painter: const _LatticePainter()),
              )
            : front
            ? _pips(base)
            : _written(base),
      ),
    );
  }
}

class _LatticePainter extends CustomPainter {
  const _LatticePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = CardPalette.gold.withValues(alpha: .55)
      ..strokeWidth = Hairline.width * 2;
    const step = Space.xl;
    for (var d = -size.height; d < size.width; d += step) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), line);
      canvas.drawLine(
        Offset(d + size.height, 0),
        Offset(d, size.height),
        line,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          Space.md,
          Space.md,
          size.width - Space.xl,
          size.height - Space.xl,
        ),
        const Radius.circular(Radii.sm),
      ),
      line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_LatticePainter old) => false;
}
