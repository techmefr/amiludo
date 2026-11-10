import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/layout_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tokens/type_roles.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.count,
    required this.current,
    required this.onSelect,
    required this.label,
    required this.completed,
    this.stepKey,
  });
  final int count, current;
  final ValueChanged<int> onSelect;
  final String label;
  final bool Function(int step) completed;
  final Key Function(int step)? stepKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: Row(
        children: [
          for (var i = 1; i <= count; i++) ...[
            if (i > 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: i <= current
                      ? scheme.accentInk
                      : scheme.outlineVariant,
                ),
              ),
            _Dot(
              key: stepKey?.call(i),
              step: i,
              active: i == current,
              done: completed(i),
              onTap: () => onSelect(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    super.key,
    required this.step,
    required this.active,
    required this.done,
    required this.onTap,
  });
  final int step;
  final bool active, done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filled = active || done;
    return InkResponse(
      onTap: onTap,
      radius: Rows.step / 2,
      child: SizedBox.square(
        dimension: Rows.step,
        child: Center(
          child: Container(
            width: Space.xxl,
            height: Space.xxl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? scheme.accentInk : Colors.transparent,
              border: Border.all(
                color: filled ? scheme.accentInk : scheme.outline,
                width: active ? 2 : 1,
              ),
            ),
            child: done && !active
                ? Icon(
                    Icons.check,
                    size: TypeScale.subtitle,
                    color: scheme.surface,
                  )
                : Text(
                    '$step',
                    style: TypeRoles.body(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: filled ? scheme.surface : scheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
