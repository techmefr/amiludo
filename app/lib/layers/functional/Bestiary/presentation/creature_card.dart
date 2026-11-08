import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Bestiary/domain/entities/creature.dart';
import 'package:amiludo/layers/functional/Bestiary/presentation/bestiary_texts.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class CreatureCard extends StatelessWidget {
  const CreatureCard({
    super.key,
    required this.creature,
    required this.tool,
    required this.onOpen,
  });
  final Creature creature;
  final ToolTheme tool;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final text = Theme.of(context).textTheme;
    final c = creature;
    final summary = [
      for (final f in c.fields.take(3))
        if (f.value.isNotEmpty) '${f.label} ${f.value}'.trim(),
    ].join('  ·  ');
    return Semantics(
      button: true,
      label: '${c.name}, ${context.creatureKindLabel(c.kind)}',
      child: Material(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: tool.accent.withValues(alpha: .45)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.md),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Row(
              children: [
                DeckIcon(creatureKindIcon(c.kind), color: ink, size: 28),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: text.titleMedium?.copyWith(color: ink),
                      ),
                      if (summary.isNotEmpty)
                        Text(
                          summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(color: ink),
                        ),
                      if (c.tags.isNotEmpty)
                        Wrap(
                          spacing: Space.xs,
                          children: [
                            for (final t in c.tags)
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(t),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
