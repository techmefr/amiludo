import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class RuleSectionCard extends StatelessWidget {
  const RuleSectionCard({
    super.key,
    required this.section,
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });
  final RuleSection section;
  final bool table;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final tool = toolThemeFor('rules');
    final surface = tool.surface(context);
    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          ToolTextureLayer(texture: tool.texture, opacity: .08),
          Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (section.title.isNotEmpty)
                        Semantics(
                          header: true,
                          child: Text(
                            section.title,
                            style:
                                (table ? text.headlineSmall : text.titleMedium)
                                    ?.copyWith(color: tool.ink(surface)),
                          ),
                        ),
                      if (section.body.isNotEmpty) ...[
                        const SizedBox(height: Space.xs),
                        SelectableText(
                          section.body,
                          style: table ? text.titleLarge : text.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!table) ...[
                  IconButton(
                    tooltip: l.rulesEditRule,
                    onPressed: onEdit,
                    icon: const DeckIcon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l.rulesDeleteRule,
                    onPressed: onDelete,
                    icon: const DeckIcon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
