import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/chronicles/table_gestures.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SwipeTable extends StatefulWidget {
  const SwipeTable({
    super.key,
    required this.child,
    required this.onKeep,
    required this.onPass,
    required this.onTap,
    this.enabled = true,
  });
  final Widget child;
  final bool enabled;
  final VoidCallback onKeep, onPass, onTap;

  @override
  State<SwipeTable> createState() => _SwipeTableState();
}

class _SwipeTableState extends State<SwipeTable> {
  double dx = 0;
  bool dragging = false;
  DateTime ignoreUntil = DateTime.fromMillisecondsSinceEpoch(0);

  bool get ignoring => DateTime.now().isBefore(ignoreUntil);

  void end(double width) {
    final outcome = swipeOutcome(dx, width);
    setState(() {
      dragging = false;
      dx = 0;
    });
    if (ignoring) return;
    switch (outcome) {
      case SwipeOutcome.keep:
        widget.onKeep();
      case SwipeOutcome.pass:
        widget.onPass();
      case SwipeOutcome.tap:
      case SwipeOutcome.none:
        break;
    }
  }

  void drag(HorizontalDragGestureRecognizer r, double width) {
    r.onStart = (_) => setState(() => dragging = true);
    r.onUpdate = (d) {
      if (widget.enabled) setState(() => dx += d.delta.dx);
    };
    r.onEnd = (_) {
      if (widget.enabled) end(width);
    };
    r.onCancel = () => setState(() {
      dragging = false;
      dx = 0;
    });
  }

  Widget stamp(String text, Alignment at, double strength, Color color) =>
      Align(
        alignment: at,
        child: Opacity(
          opacity: strength.clamp(0.0, 1.0),
          child: Container(
            padding: const EdgeInsets.all(Space.sm),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Text(text, style: TextStyle(color: color)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final width = c.maxWidth;
      final strength = dx.abs() / (width * keepThreshold);
      final scheme = Theme.of(context).colorScheme;
      return RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          HorizontalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                HorizontalDragGestureRecognizer
              >(
                HorizontalDragGestureRecognizer.new,
                (r) => drag(r, width),
              ),
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                TapGestureRecognizer.new,
                (r) => r.onTap = () {
                  if (widget.enabled && !ignoring) {
                    ignoreUntil = DateTime.now().add(detailIgnore);
                    widget.onTap();
                  }
                },
              ),
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: dx),
              duration: dragging
                  ? Duration.zero
                  : Motion.of(context, Motion.slow),
              curve: Curves.elasticOut,
              builder: (context, x, child) => Transform.translate(
                offset: Offset(x, 0),
                child: Transform.rotate(angle: x / width * 0.3, child: child),
              ),
              child: widget.child,
            ),
            if (dx > 0)
              stamp(
                context.l10n.chroniclesKeep,
                Alignment.topLeft,
                strength,
                scheme.primary,
              ),
            if (dx < 0)
              stamp(
                context.l10n.chroniclesPass,
                Alignment.topRight,
                strength,
                scheme.error,
              ),
          ],
        ),
      );
    },
  );
}
