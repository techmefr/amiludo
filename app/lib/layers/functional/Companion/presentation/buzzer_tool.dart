import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/presentation/life_palette.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class BuzzerTool extends StatefulWidget {
  const BuzzerTool({super.key, required this.names});
  final List<String> names;

  @override
  State<BuzzerTool> createState() => _BuzzerToolState();
}

class _BuzzerToolState extends State<BuzzerTool> {
  int? winner;
  final tool = toolThemeFor('buzzer');

  void _press(int index) {
    if (winner != null) return;
    tool.signal();
    setState(() => winner = index);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final won = winner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            won == null ? l.buzzerReady : l.buzzerFirst(widget.names[won]),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: Space.lg),
        LayoutBuilder(
          builder: (context, box) {
            final columns = box.maxWidth > 560 ? 3 : 2;
            return Wrap(
              spacing: Space.md,
              runSpacing: Space.md,
              children: [
                for (final (i, name) in widget.names.indexed)
                  SizedBox(
                    width: (box.maxWidth - (columns - 1) * Space.md) / columns,
                    height: 150,
                    child: Semantics(
                      button: true,
                      label: name,
                      child: GestureDetector(
                        onTapDown: (_) => _press(i),
                        child: ExcludeSemantics(
                          child: AnimatedOpacity(
                            duration: Motion.of(context, Motion.base),
                            opacity: won == null || won == i ? 1 : .35,
                            child: StoneSlab(
                              accent: playerTints[i % playerTints.length],
                              halo: won == i ? StonePalette.gold : null,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(Space.md),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      name,
                                      style: stoneNumerals(TypeScale.headline),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: Space.lg),
        Center(
          child: FilledButton.icon(
            onPressed: won == null ? null : () => setState(() => winner = null),
            icon: const DeckIcon(Icons.restart_alt),
            label: Text(l.appearanceReset),
          ),
        ),
      ],
    );
  }
}
