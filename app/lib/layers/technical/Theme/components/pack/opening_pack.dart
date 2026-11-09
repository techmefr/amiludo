import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/pack/pack_timing.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';

class OpeningPack extends StatelessWidget {
  const OpeningPack({
    super.key,
    required this.progress,
    required this.width,
    this.style = TarotStyle.nightGold,
  });
  final double progress, width;
  final TarotStyle style;

  static const double _flap = .22;

  @override
  Widget build(BuildContext context) {
    final shake = packSpan(progress, 0, PackBeat.shakeEnd);
    final tear = Curves.easeIn.transform(
      packSpan(progress, PackBeat.shakeEnd, PackBeat.tearEnd),
    );
    final gone = packSpan(progress, PackBeat.tearEnd, PackBeat.packGone);
    if (gone >= 1) return const SizedBox.shrink();
    final intensity = shake * shake;
    final dx = math.sin(shake * math.pi * 22) * intensity * width * .08;
    final tilt = math.sin(shake * math.pi * 17) * intensity * .06;
    final back = TarotBack(style: style, width: width);
    final height = width / tarotRatio;
    return Opacity(
      opacity: 1 - gone,
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Transform.rotate(
          angle: tilt,
          child: Transform.scale(
            scale: 1 + .05 * shake,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: style.glow.withValues(alpha: .7 * shake),
                    blurRadius: width * .5 * shake,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(-width * .12 * tear, -height * .14 * tear),
                    child: Transform.rotate(
                      angle: -.8 * tear,
                      alignment: Alignment.bottomLeft,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: _flap,
                          child: back,
                        ),
                      ),
                    ),
                  ),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 1 - _flap,
                      child: back,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
