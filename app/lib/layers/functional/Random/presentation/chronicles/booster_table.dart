import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/chronicles/table_gestures.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';

class BoosterTable extends StatefulWidget {
  const BoosterTable({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTear,
    required this.onStep,
  });
  final String title, subtitle;
  final VoidCallback onTear;
  final ValueChanged<int> onStep;

  @override
  State<BoosterTable> createState() => _BoosterTableState();
}

class _BoosterTableState extends State<BoosterTable> {
  double dx = 0;
  bool dragging = false;

  void end(double width) {
    final outcome = boosterOutcome(dx, width);
    setState(() {
      dx = 0;
      dragging = false;
    });
    switch (outcome) {
      case BoosterOutcome.tear:
        widget.onTear();
      case BoosterOutcome.previous:
        widget.onStep(-1);
      case BoosterOutcome.next:
        widget.onStep(1);
      case BoosterOutcome.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = tableHeight(MediaQuery.sizeOf(context)) * 0.5;
    return LayoutBuilder(
      builder: (context, c) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => dragging = true),
        onHorizontalDragUpdate: (d) => setState(() => dx += d.delta.dx),
        onHorizontalDragEnd: (_) => end(c.maxWidth),
        onHorizontalDragCancel: () => setState(() {
          dx = 0;
          dragging = false;
        }),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: dx),
          duration: dragging ? Duration.zero : Motion.of(context, Motion.base),
          curve: Curves.elasticOut,
          builder: (context, x, child) =>
              Transform.translate(offset: Offset(x, 0), child: child),
          child: Container(
            key: const ValueKey('booster-table'),
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: theme.colorScheme.accentInk, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: theme.textTheme.headlineSmall),
                Text(widget.subtitle),
                const SizedBox(height: Space.sm),
                Text(
                  context.l10n.chroniclesTearHint,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
