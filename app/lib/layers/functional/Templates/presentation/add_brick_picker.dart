import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

Future<Brick?> pickBrick(BuildContext context) => showModalBottomSheet<Brick>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: .8,
    maxChildSize: .95,
    builder: (context, controller) => _BrickPicker(controller: controller),
  ),
);

class _BrickPicker extends StatelessWidget {
  const _BrickPicker({required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) => ListView(
    controller: controller,
    padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.xl),
    children: [
      Text(
        context.l10n.buildAdd,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      for (final shelf in toolShelves) ...[
        Padding(
          padding: const EdgeInsets.only(top: Space.xl, bottom: Space.sm),
          child: Semantics(
            header: true,
            child: Text(
              context.toolShelfLabel(shelf.id),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [for (final id in shelf.tools) _choice(context, id)],
        ),
      ],
    ],
  );

  Widget _choice(BuildContext context, String id) {
    final entry = brickEntries.firstWhere((e) => e.id == id);
    final tool = toolThemeFor(id);
    final surface = tool.surface(context);
    return ActionChip(
      avatar: DeckIcon(toolIcon(id), size: 18, color: tool.ink(surface)),
      label: Text(context.toolTitle(id)),
      backgroundColor: surface,
      onPressed: () => Navigator.pop(context, entry.toBrick()),
    );
  }
}
