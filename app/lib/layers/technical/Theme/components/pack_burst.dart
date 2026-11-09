import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Theme/components/sparkle_rain.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_flip.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';

class PackBurst extends StatefulWidget {
  const PackBurst({
    super.key,
    required this.count,
    required this.rareIndex,
    required this.faceBuilder,
    this.style = TarotStyle.nightGold,
    this.cardWidth = 110,
    this.onDone,
  });
  final int count, rareIndex;
  final Widget Function(int index, double width) faceBuilder;
  final TarotStyle style;
  final double cardWidth;
  final VoidCallback? onDone;

  @override
  State<PackBurst> createState() => _PackBurstState();
}

class _PackBurstState extends State<PackBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );
  bool _started = false;
  int _beat = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _controller.addListener(_haptics);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      widget.onDone?.call();
    } else {
      _controller.forward().whenComplete(() => widget.onDone?.call());
    }
  }

  void _haptics() {
    final t = _controller.value;
    if (_beat == 0 && t > .02) {
      _beat = 1;
      DeckHaptics.selection();
    } else if (_beat == 1 && t > .22) {
      _beat = 2;
      DeckHaptics.impact();
    } else if (_beat == 2 && t > .68) {
      _beat = 3;
      DeckHaptics.impact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _span(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  Widget _pack(double t) {
    final shake = _span(t, 0, .22);
    final tear = _span(t, .22, .3);
    final dx = math.sin(shake * math.pi * 14) * shake * widget.cardWidth * .06;
    if (tear >= 1) return const SizedBox.shrink();
    return Transform.translate(
      offset: Offset(dx, 0),
      child: Transform.scale(
        scale: 1 + .35 * tear,
        child: Opacity(
          opacity: 1 - tear,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.style.glow.withValues(alpha: .7 * shake),
                  blurRadius: widget.cardWidth * .5 * shake,
                ),
              ],
            ),
            child: TarotBack(style: widget.style, width: widget.cardWidth),
          ),
        ),
      ),
    );
  }

  Widget _card(int i, double t) {
    final fan = Curves.easeOutBack.transform(_span(t, .3, .62));
    final mid = (widget.count - 1) / 2;
    final offset = i - mid;
    final rare = i == widget.rareIndex;
    final tremble = rare && t > .45 && t < .65
        ? math.sin(t * 90) * widget.cardWidth * .015
        : 0.0;
    final flip = _span(t, .65, .85);
    return Transform.translate(
      offset: Offset(offset * widget.cardWidth * .5 * fan + tremble, 0),
      child: Transform.rotate(
        angle: offset * .16 * fan,
        alignment: Alignment.bottomCenter,
        child: Transform.translate(
          offset: Offset(0, rare && flip > 0 ? -widget.cardWidth * .12 : 0),
          child: TarotFlip(
            flipped: rare && flip > 0,
            sheen: rare ? widget.style.glow : null,
            back: TarotBack(style: widget.style, width: widget.cardWidth),
            front: widget.faceBuilder(i, widget.cardWidth),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.cardWidth / tarotRatio * 1.3;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final flash = math.sin(_span(t, .2, .34) * math.pi);
        final rareFirst = [
          for (var i = 0; i < widget.count; i++)
            if (i != widget.rareIndex) i,
          widget.rareIndex,
        ];
        return SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (t >= .3 || reduced)
                for (final i in rareFirst) _card(i, reduced ? 1 : t),
              if (!reduced) _pack(t),
              if (!reduced && flash > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: const Color(0xffffffff)
                          .withValues(alpha: flash * .8),
                    ),
                  ),
                ),
              if (!reduced)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: SparkleRainPainter(
                        progress: _span(t, .85, 1),
                        color: const Color(0xffe5c97a),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
