import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/blur_bar.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class LargeTitleHeader extends SliverPersistentHeaderDelegate {
  const LargeTitleHeader({
    required this.title,
    required this.top,
    this.leading,
    this.actions = const [],
    this.inset = Space.xl,
  });
  final String title;
  final double top;
  final Widget? leading;
  final List<Widget> actions;
  final double inset;

  static const double _bar = kToolbarHeight;
  static const double _large = 52;

  @override
  double get minExtent => top + _bar;
  @override
  double get maxExtent => top + _bar + _large;

  @override
  Widget build(BuildContext context, double shrink, bool overlaps) {
    final theme = Theme.of(context);
    final t = (shrink / _large).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: t,
          child: const BlurBar(top: true, child: SizedBox.expand()),
        ),
        Positioned(
          top: top,
          left: Space.xs,
          right: Space.xs,
          height: _bar,
          child: Row(
            children: [
              SizedBox(width: Targets.minimum, child: leading),
              Expanded(
                child: ExcludeSemantics(
                  child: Opacity(
                    opacity: t,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              ...actions,
              if (actions.isEmpty) const SizedBox(width: Targets.minimum),
            ],
          ),
        ),
        Positioned(
          left: inset,
          right: inset,
          bottom: Space.xs,
          child: Opacity(
            opacity: 1 - t,
            child: Semantics(
              header: true,
              child: Text(
                title,
                key: const ValueKey('screen-title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(LargeTitleHeader old) =>
      old.title != title ||
      old.top != top ||
      old.inset != inset ||
      old.leading != leading ||
      old.actions != actions;
}
