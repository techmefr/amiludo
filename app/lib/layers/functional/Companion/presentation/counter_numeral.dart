import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CounterNumeral extends StatefulWidget {
  const CounterNumeral({
    super.key,
    required this.text,
    required this.value,
    this.size = TypeScale.display * 2,
  });
  final String text;
  final double size;
  final double value;

  @override
  State<CounterNumeral> createState() => _CounterNumeralState();
}

class _CounterNumeralState extends State<CounterNumeral>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.fast,
    value: 1,
  );
  double _direction = 1;

  @override
  void didUpdateWidget(CounterNumeral old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;
    _direction = widget.value > old.value ? 1 : -1;
    if (!MediaQuery.disableAnimationsOf(context)) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutBack.transform(_controller.value);
        return Opacity(
          opacity: (.3 + .7 * _controller.value).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _direction * (1 - t) * Space.xl),
            child: child,
          ),
        );
      },
      child: Text(widget.text, style: stoneNumerals(widget.size)),
    ),
  );
}
