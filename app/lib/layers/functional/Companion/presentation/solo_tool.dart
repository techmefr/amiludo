import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/solo_deck.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

String soloActionLabel(BuildContext context, String id) {
  final l = context.l10n;
  return switch (id) {
    'attack' => l.soloAttack,
    'build' => l.soloBuild,
    'defend' => l.soloDefend,
    'expand' => l.soloExpand,
    'trade' => l.soloTrade,
    _ => l.soloGather,
  };
}

class SoloTool extends StatefulWidget {
  const SoloTool({super.key, this.random});
  final Random? random;

  @override
  State<SoloTool> createState() => _SoloToolState();
}

class _SoloToolState extends State<SoloTool> {
  late final Random random = widget.random ?? Random();
  late SoloDeck deck = SoloDeck.shuffled(random);
  int level = 1;
  final tool = toolThemeFor('solo');

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final current = deck.current;
    final text = current == null ? '?' : soloActionLabel(context, current);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          children: [
            for (final option in soloLevels)
              ChoiceChip(
                label: Text(l.soloLevel(option)),
                selected: option == level,
                onSelected: (_) => setState(() => level = option),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Semantics(
          liveRegion: true,
          label: text,
          child: StoneSlab(
            accent: tool.accent,
            child: SizedBox(
              height: 200,
              child: Center(
                child: AnimatedSwitcher(
                  duration: Motion.of(context, Motion.base),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Column(
                    key: ValueKey('${deck.drawn.length}$text'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          text,
                          style: stoneNumerals(TypeScale.display * 1.3),
                        ),
                      ),
                      if (current != null && level > 0)
                        Text(
                          l.soloBonus(level),
                          style: theme.titleMedium?.copyWith(
                            color: StonePalette.gold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Text(
          l.soloRemaining(deck.pile.length),
          textAlign: TextAlign.center,
          style: theme.bodyMedium,
        ),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.sm,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () {
                tool.signal();
                setState(() => deck = deck.draw(random));
              },
              icon: const DeckIcon(Icons.style_outlined),
              label: Text(l.soloDraw),
            ),
            TextButton(
              onPressed: () =>
                  setState(() => deck = SoloDeck.shuffled(random)),
              child: Text(l.appearanceReset),
            ),
          ],
        ),
      ],
    );
  }
}
