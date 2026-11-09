import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/generator_content.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const generatorGlyphs = <String, IconData>{
  'npc': Icons.person_outline,
  'tavern': Icons.sports_bar_outlined,
  'encounter': Icons.shield_outlined,
  'quest': Icons.flag_outlined,
  'treasure': Icons.diamond_outlined,
  'villain': Icons.masks_outlined,
  'town': Icons.location_city_outlined,
  'magicitem': Icons.auto_fix_high_outlined,
  'weather': Icons.thunderstorm_outlined,
  'place': Icons.landscape_outlined,
  'dilemma': Icons.balance_outlined,
  'rumour': Icons.hearing_outlined,
  'trait': Icons.psychology_outlined,
  'twist': Icons.change_circle_outlined,
};

class GeneratorCard extends StatelessWidget {
  const GeneratorCard({super.key, required this.id, required this.sheet});
  final String id;
  final GeneratedSheet sheet;

  @override
  Widget build(BuildContext context) {
    final tool = toolThemeFor(id);
    final surface = tool.surface(context, mix: .14);
    final ink = tool.ink(surface);
    final text = Theme.of(context).textTheme;
    final body = Theme.of(context).colorScheme.onSurface;
    return AnimatedContainer(
      duration: Motion.of(context, Motion.base),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: tool.accent, width: Hairline.width * 3),
        boxShadow: [
          BoxShadow(
            color: tool.accent.withValues(alpha: .25),
            blurRadius: Space.lg,
            offset: const Offset(0, Space.sm),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Stack(
          children: [
            ToolTextureLayer(texture: tool.texture, opacity: .08),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: tool.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(Space.sm),
                          child: DeckIcon(
                            generatorGlyphs[id] ?? Icons.auto_awesome,
                            color: tool.ink(tool.accent, ratio: 4.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          child: SelectableText(
                            sheet.title,
                            style: text.headlineSmall?.copyWith(color: ink),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.md),
                  for (final section in sheet.sections) ...[
                    Text(
                      section.label,
                      style: text.labelLarge?.copyWith(
                        color: ink,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: Space.xs),
                    for (final line in section.lines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.xs),
                        child: SelectableText(
                          line,
                          style: text.bodyMedium?.copyWith(color: body),
                        ),
                      ),
                    const SizedBox(height: Space.md),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
