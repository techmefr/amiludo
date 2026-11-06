import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const fingerColors = [
  Color(0xFFE040B0),
  Color(0xFF1FB5D6),
  Color(0xFFFFD60A),
  Color(0xFF8BDB3C),
  Color(0xFFFF5A4D),
  Color(0xFFFF9500),
];

const fingerPadColor = Color(0xFF121212);
const fingerHintColor = Color(0xB3FFFFFF);
const fingerIdleColor = Color(0x8AFFFFFF);

enum FingerRingState { idle, dim, winner }

class FingerRing extends StatelessWidget {
  const FingerRing({
    super.key,
    required this.color,
    this.state = FingerRingState.idle,
    this.label,
    this.size = 88,
  });

  final Color color;
  final FingerRingState state;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dim = state == FingerRingState.dim;
    final winner = state == FingerRingState.winner;
    final base = dim ? const Color(0xFF3A3A3C) : color;
    final inner = size * 0.62;
    final core = size * 0.44;
    return AnimatedContainer(
      duration: Motion.of(context, Motion.base),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: base.withValues(alpha: dim ? 0.5 : 0.55),
        boxShadow: winner
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.7),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
              ]
            : const [],
      ),
      child: Container(
        width: inner,
        height: inner,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: fingerPadColor,
        ),
        child: Container(
          width: core,
          height: core,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: base),
          child: label == null
              ? null
              : Text(
                  label!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
