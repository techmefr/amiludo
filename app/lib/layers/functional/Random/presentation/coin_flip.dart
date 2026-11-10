import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/coin_face.dart';
import 'package:amiludo/layers/technical/Motion/coin_toss.dart';
import 'package:amiludo/layers/technical/Theme/game_palette.dart';

class CoinFlip extends StatefulWidget {
  const CoinFlip({
    super.key,
    required this.heads,
    required this.flipId,
    required this.size,
    required this.height,
    this.onLanded,
    this.artwork,
  });
  final bool? heads;
  final int flipId;
  final double size, height;
  final VoidCallback? onLanded;
  final Widget? Function(bool heads, double size)? artwork;

  @override
  State<CoinFlip> createState() => _CoinFlipState();
}

class _CoinFlipState extends State<CoinFlip>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
    value: 1,
  );
  late CoinToss toss = CoinToss(heads: widget.heads ?? true);

  @override
  void didUpdateWidget(CoinFlip old) {
    super.didUpdateWidget(old);
    if (widget.flipId == old.flipId || widget.heads == null) return;
    final reduced = MediaQuery.disableAnimationsOf(context);
    toss = CoinToss(
      heads: widget.heads!,
      turns: 3 + widget.flipId % 3,
      reduced: reduced,
    );
    controller.duration = Duration(milliseconds: reduced ? 220 : 1400);
    controller.forward(from: 0).whenComplete(() {
      if (mounted) scheduleMicrotask(() => widget.onLanded?.call());
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget coin(double t) {
    final heads = toss.showsHeads(t);
    final spin = Matrix4.identity()
      ..setEntry(3, 2, .0018)
      ..rotateX(toss.angle(t));
    return Transform(
      alignment: Alignment.center,
      transform: spin,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(heads ? 0 : pi),
        child: CoinFace(
          heads: heads,
          size: widget.size,
          artwork: widget.artwork?.call(heads, widget.size),
        ),
      ),
    );
  }

  Widget shadow(double lift) => Container(
    width: widget.size * (1 - lift * .45),
    height: widget.size * .14,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: GamePalette.ink.withValues(alpha: .42 - lift * .25),
    ),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.height,
    child: AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final lift = toss.lift(t);
        final room = widget.height - widget.size * 1.2;
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            shadow(lift),
            Positioned(bottom: widget.size * .1 + room * lift, child: coin(t)),
          ],
        );
      },
    ),
  );
}
