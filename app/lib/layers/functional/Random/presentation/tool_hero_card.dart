import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/tool_preview.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_badge.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_texture.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class ToolHeroCard extends StatelessWidget {
  const ToolHeroCard({
    super.key,
    required this.id,
    required this.resume,
    required this.onOpen,
  });
  final String id;
  final bool resume;
  final VoidCallback onOpen;

  static const double _wide = 600;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final tool = toolThemeFor(id);
    final wide = MediaQuery.sizeOf(context).width >= _wide;
    final preview = Hero(
      tag: toolHeroTag(id),
      child: Stack(
        children: [
          ToolTextureLayer(texture: tool.texture, opacity: .09),
          ToolPreview(id: id, height: wide ? 180 : 140),
        ],
      ),
    );
    final info = Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            resume ? l.toolHeroResume : l.toolHeroFeatured,
            style: text.labelLarge,
          ),
          const SizedBox(height: Space.xs),
          Text(context.toolTitle(id), style: text.headlineSmall),
          const SizedBox(height: Space.sm),
          Text(context.toolSubtitle(id), style: text.bodyMedium),
          const SizedBox(height: Space.lg),
          FilledButton(onPressed: onOpen, child: Text(l.workspaceOpen)),
        ],
      ),
    );
    return Material(
      color: tool.surface(context, mix: .18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: wide
          ? Row(
              children: [
                Expanded(child: preview),
                Expanded(child: info),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [preview, info],
            ),
    );
  }
}
