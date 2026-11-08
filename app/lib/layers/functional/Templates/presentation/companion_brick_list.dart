import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_brick_row.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CompanionBrickList extends StatelessWidget {
  const CompanionBrickList({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.onSettings,
  });
  final Companion draft;
  final ValueChanged<Companion> onChanged;
  final ValueChanged<Brick> onSettings;

  @override
  Widget build(BuildContext context) {
    final bricks = draft.bricks;
    if (bricks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xl),
        child: Text(context.l10n.buildEmpty),
      );
    }
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorderItem: (from, to) => onChanged(draft.move(from, to)),
      children: [
        for (var i = 0; i < bricks.length; i++)
          Padding(
            key: ValueKey(bricks[i].id),
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: CompanionBrickRow(
              brick: bricks[i],
              onResize: (size) =>
                  onChanged(draft.replace(bricks[i].resized(size))),
              onSettings: () => onSettings(bricks[i]),
              onRemove: () => onChanged(draft.remove(bricks[i].id)),
              onEarlier: i == 0 ? null : () => onChanged(draft.move(i, i - 1)),
              onLater: i == bricks.length - 1
                  ? null
                  : () => onChanged(draft.move(i, i + 1)),
            ),
          ),
      ],
    );
  }
}
