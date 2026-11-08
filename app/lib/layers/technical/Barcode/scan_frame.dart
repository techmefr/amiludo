import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ScanFrame extends StatefulWidget {
  const ScanFrame({
    super.key,
    required this.child,
    required this.label,
    this.busy = false,
  });

  final Widget child;
  final String label;
  final bool busy;

  @override
  State<ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<ScanFrame>
    with SingleTickerProviderStateMixin {
  static const sweeps = 6;

  late final AnimationController sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      sweep
        ..stop()
        ..value = .5;
    } else if (!sweep.isAnimating) {
      sweep.repeat(reverse: true, count: sweeps);
    }
  }

  @override
  void didUpdateWidget(ScanFrame old) {
    super.didUpdateWidget(old);
    if (old.busy && !widget.busy && !sweep.isAnimating) {
      sweep.repeat(reverse: true, count: sweeps);
    }
  }

  @override
  void dispose() {
    sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            IgnorePointer(
              child: AnimatedBuilder(
                animation: sweep,
                builder: (context, _) => TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    end: widget.busy ? scheme.tertiary : scheme.primary,
                  ),
                  duration: Motion.of(context, Motion.base),
                  builder: (context, color, _) => CustomPaint(
                    painter: FramePainter(
                      color: color ?? scheme.primary,
                      shadow: scheme.scrim.withValues(alpha: .45),
                      progress: sweep.value,
                      busy: widget.busy,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FramePainter extends CustomPainter {
  const FramePainter({
    required this.color,
    required this.shadow,
    required this.progress,
    required this.busy,
  });

  final Color color, shadow;
  final double progress;
  final bool busy;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Offset(28, 28) & Size(size.width - 56, size.height - 56);
    const arm = 30.0;
    for (final (stroke, paint) in [(8.0, shadow), (4.0, color)]) {
      final pen = Paint()
        ..color = paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      for (final (corner, dx, dy) in [
        (box.topLeft, 1.0, 1.0),
        (box.topRight, -1.0, 1.0),
        (box.bottomLeft, 1.0, -1.0),
        (box.bottomRight, -1.0, -1.0),
      ]) {
        canvas.drawPath(
          Path()
            ..moveTo(corner.dx + dx * arm, corner.dy)
            ..lineTo(corner.dx, corner.dy)
            ..lineTo(corner.dx, corner.dy + dy * arm),
          pen,
        );
      }
    }
    if (busy) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(Radii.sm)),
        Paint()..color = color.withValues(alpha: .16),
      );
      return;
    }
    final y = box.top + box.height * progress;
    canvas.drawLine(
      Offset(box.left + 12, y),
      Offset(box.right - 12, y),
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(FramePainter old) =>
      old.progress != progress || old.color != color || old.busy != busy;
}
