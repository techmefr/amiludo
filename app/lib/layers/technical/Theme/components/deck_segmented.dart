import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DeckSegmented<T> extends StatelessWidget {
  const DeckSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  static const double _inset = 2;

  Widget _thumb(BuildContext context, int index) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final count = options.length;
    return Positioned.fill(
      child: AnimatedAlign(
        alignment: Alignment(count == 1 ? 0 : -1 + 2 * index / (count - 1), 0),
        duration: Motion.of(context, Motion.base),
        curve: Motion.spring,
        child: FractionallySizedBox(
          widthFactor: 1 / count,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: dark
                  ? Color.alphaBlend(
                      scheme.onSurface.withValues(alpha: .24),
                      scheme.surface,
                    )
                  : scheme.surface,
              borderRadius: BorderRadius.circular(Radii.control - _inset),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: .12),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _segment(BuildContext context, T value, String label) {
    final theme = Theme.of(context);
    final active = value == selected;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        excludeSemantics: true,
        label: label,
        onTap: () => onChanged(value),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.control),
          onTap: () {
            DeckHaptics.selection();
            onChanged(value);
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Targets.minimum - 2 * _inset,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.sm),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = options.indexWhere((o) => o.$1 == selected);
    return Container(
      padding: const EdgeInsets.all(_inset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      child: Stack(
        children: [
          if (index >= 0) _thumb(context, index),
          Row(
            children: [
              for (final (value, label) in options)
                _segment(context, value, label),
            ],
          ),
        ],
      ),
    );
  }
}
