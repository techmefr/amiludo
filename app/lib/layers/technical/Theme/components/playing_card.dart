import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';
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
    this.backStyle = TarotStyle.nightGold,
  });

  final String? rank, suit, label;
  final bool red, faceDown;
  final double width;
  final TarotStyle backStyle;

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
    if (faceDown) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: TarotBack(style: backStyle, width: height * tarotRatio),
        ),
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CardPalette.paper,
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
        child: front ? _pips(base) : _written(base),
      ),
    );
  }
}
