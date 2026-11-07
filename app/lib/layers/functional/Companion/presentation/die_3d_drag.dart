import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class Die3dDrag extends StatefulWidget {
  const Die3dDrag({
    super.key,
    required this.spec,
    required this.value,
    required this.skin,
    this.flipX = 0,
    this.flipY = 0,
    this.size = 56,
  });
  final DiceSpec spec;
  final int value;
  final DieSkin skin;
  final double flipX, flipY, size;

  @override
  State<Die3dDrag> createState() => _Die3dDragState();
}

class _Die3dDragState extends State<Die3dDrag>
    with SingleTickerProviderStateMixin {
  late final AnimationController release = AnimationController(
    vsync: this,
    duration: Motion.slow,
  )..addListener(() => setState(() => turn = from * (1 - _ease(release.value))));
  Offset turn = Offset.zero, from = Offset.zero;

  double _ease(double t) => Curves.easeOutBack.transform(t);

  @override
  void dispose() {
    release.dispose();
    super.dispose();
  }

  void _drag(DragUpdateDetails d) {
    release.stop();
    setState(() => turn += d.delta / widget.size);
  }

  void _drop(DragEndDetails _) {
    from = turn;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => turn = Offset.zero);
      return;
    }
    release.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onPanUpdate: _drag,
    onPanEnd: _drop,
    child: Die3dView(
      spec: widget.spec,
      value: widget.value,
      skin: widget.skin,
      size: widget.size,
      flipX: widget.flipX - turn.dy,
      flipY: widget.flipY + turn.dx,
    ),
  );
}
