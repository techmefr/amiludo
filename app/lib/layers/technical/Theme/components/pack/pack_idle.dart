import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';

class PackIdle extends StatefulWidget {
  const PackIdle({
    super.key,
    required this.width,
    required this.onTap,
    required this.label,
    this.style = TarotStyle.nightGold,
  });
  final double width;
  final VoidCallback onTap;
  final String label;
  final TarotStyle style;

  @override
  State<PackIdle> createState() => _PackIdleState();
}

class _PackIdleState extends State<PackIdle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = .5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    onTap: widget.onTap,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final wave = math.sin(_controller.value * 2 * math.pi);
          return Transform.translate(
            offset: Offset(0, -wave * widget.width * .035),
            child: Transform.rotate(
              angle: wave * .015,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: widget.style.glow.withValues(
                        alpha: .3 + .3 * wave,
                      ),
                      blurRadius: widget.width * .4,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        },
        child: TarotBack(style: widget.style, width: widget.width),
      ),
    ),
  );
}
