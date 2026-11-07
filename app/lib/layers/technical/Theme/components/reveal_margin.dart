import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RevealMargin extends SingleChildRenderObjectWidget {
  const RevealMargin({super.key, required this.top, super.child});
  final double top;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderRevealMargin(top);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderRevealMargin).top = top;
  }
}

class _RenderRevealMargin extends RenderProxyBox {
  _RenderRevealMargin(this.top);
  double top;

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final target = rect ?? descendant?.paintBounds;
    super.showOnScreen(
      descendant: descendant,
      rect: target == null
          ? null
          : Rect.fromLTRB(
              target.left,
              target.top - top,
              target.right,
              target.bottom,
            ),
      duration: duration,
      curve: curve,
    );
  }
}
