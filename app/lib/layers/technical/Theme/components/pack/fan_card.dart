import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/flip_sparkle_painter.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_flip.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';

class FanCard extends StatefulWidget {
  const FanCard({
    super.key,
    required this.front,
    required this.width,
    required this.rarity,
    required this.label,
    required this.onRevealed,
    this.style = TarotStyle.nightGold,
  });
  final Widget front;
  final double width, rarity;
  final String label;
  final VoidCallback onRevealed;
  final TarotStyle style;

  @override
  State<FanCard> createState() => _FanCardState();
}

class _FanCardState extends State<FanCard> with SingleTickerProviderStateMixin {
  late final AnimationController _sparkle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _flipped = false;

  void _reveal() {
    if (_flipped) return;
    setState(() => _flipped = true);
    if (widget.rarity > .66) {
      DeckHaptics.heavy();
    } else {
      DeckHaptics.impact();
    }
    if (!MediaQuery.disableAnimationsOf(context)) _sparkle.forward();
    widget.onRevealed();
  }

  @override
  void dispose() {
    _sparkle.dispose();
    super.dispose();
  }

  Widget _glow() => Positioned.fill(
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.width * .06),
        boxShadow: [
          BoxShadow(
            color: widget.style.glow.withValues(alpha: .2 + .6 * widget.rarity),
            blurRadius: widget.width * (.15 + .35 * widget.rarity),
            spreadRadius: widget.width * .04 * widget.rarity,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final reach = widget.width * .4;
    return Semantics(
      button: !_flipped,
      label: _flipped ? null : widget.label,
      onTap: _flipped ? null : _reveal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _reveal,
        child: AnimatedBuilder(
          animation: _sparkle,
          builder: (_, child) => Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (_flipped) _glow(),
              child!,
              Positioned(
                left: -reach,
                right: -reach,
                top: -reach,
                bottom: -reach,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: FlipSparklePainter(
                      progress: _sparkle.value,
                      rarity: widget.rarity,
                      color: widget.style.glow,
                    ),
                  ),
                ),
              ),
            ],
          ),
          child: TarotFlip(
            flipped: _flipped,
            sheen: widget.rarity > .33 ? widget.style.glow : null,
            back: TarotBack(style: widget.style, width: widget.width),
            front: SizedBox(width: widget.width, child: widget.front),
          ),
        ),
      ),
    );
  }
}
