import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class AvatarColorRow extends StatelessWidget {
  const AvatarColorRow({
    super.key,
    required this.colors,
    required this.selected,
    required this.onPick,
  });
  final List<int> colors;
  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: Space.sm,
      runSpacing: Space.sm,
      children: [
        for (final c in colors)
          Semantics(
            button: true,
            selected: (selected ?? colors.first) == c,
            label: context.l10n.avatarColor,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onPick(c),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(c),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: (selected ?? colors.first) == c ? 3 : 1,
                    color: (selected ?? colors.first) == c
                        ? scheme.primary
                        : scheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
