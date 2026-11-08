import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Scenes/domain/entities/scene.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class SceneCard extends StatelessWidget {
  const SceneCard({
    super.key,
    required this.scene,
    required this.number,
    required this.followers,
    required this.creatureNames,
    required this.tool,
    required this.onOpen,
    required this.onShow,
    this.onUp,
    this.onDown,
  });
  final Scene scene;
  final int number;
  final List<Scene> followers;
  final List<String> creatureNames;
  final ToolTheme tool;
  final VoidCallback onOpen, onShow;
  final VoidCallback? onUp, onDown;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final surface = tool.surface(context);
    final ink = tool.ink(surface);
    final text = Theme.of(context).textTheme;
    return Material(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '$number',
                  textAlign: TextAlign.center,
                  style: Numerals.instrument(
                    text.headlineSmall,
                  )?.copyWith(color: ink),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.title,
                      style: text.titleMedium?.copyWith(color: ink),
                    ),
                    if (scene.notes.isNotEmpty)
                      Text(
                        scene.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(color: ink),
                      ),
                    Wrap(
                      spacing: Space.xs,
                      children: [
                        for (final s in followers)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: const DeckIcon(Icons.chevron_right),
                            label: Text(s.title),
                          ),
                        for (final name in creatureNames)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: const DeckIcon(Icons.person_outline),
                            label: Text(name),
                          ),
                      ],
                    ),
                    if (scene.hasHandout)
                      TextButton.icon(
                        onPressed: onShow,
                        icon: const DeckIcon(Icons.visibility_outlined),
                        label: Text(l.scenesShow),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    tooltip: l.scenesMoveUp(scene.title),
                    onPressed: onUp,
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    tooltip: l.scenesMoveDown(scene.title),
                    onPressed: onDown,
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
