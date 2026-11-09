import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/sport_score.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

String _modeLabel(BuildContext context, String id) => switch (id) {
  'darts' => context.l10n.sportDarts,
  'petanque' => context.l10n.sportPetanque,
  _ => context.l10n.sportMolkky,
};

class SportTool extends StatefulWidget {
  const SportTool({super.key, required this.names});
  final List<String> names;

  @override
  State<SportTool> createState() => _SportToolState();
}

class _SportToolState extends State<SportTool> {
  SportMode mode = sportModes.first;
  late List<int> scores = _fresh();
  late final List<TextEditingController> inputs = [
    for (final _ in widget.names) TextEditingController(),
  ];
  final tool = toolThemeFor('sport');

  List<int> _fresh() => [for (final _ in widget.names) mode.start];

  @override
  void dispose() {
    for (final input in inputs) {
      input.dispose();
    }
    super.dispose();
  }

  void _add(int player) {
    final points = int.tryParse(inputs[player].text.trim());
    if (points == null) return;
    tool.signal();
    inputs[player].clear();
    setState(
      () => scores = [
        for (final (i, s) in scores.indexed)
          i == player ? mode.apply(s, points) : s,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Space.sm,
          children: [
            for (final option in sportModes)
              ChoiceChip(
                label: Text(_modeLabel(context, option.id)),
                selected: option.id == mode.id,
                onSelected: (_) => setState(() {
                  mode = option;
                  scores = _fresh();
                }),
              ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Text(l.sportGoal(mode.target), style: theme.bodyMedium),
        const SizedBox(height: Space.lg),
        for (final (i, name) in widget.names.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: StoneSlab(
              accent: tool.accent,
              halo: mode.won(scores[i]) ? StonePalette.gold : null,
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        mode.won(scores[i]) ? '$name · ${l.rankingStamp}' : name,
                        style: theme.titleMedium?.copyWith(
                          color: StonePalette.cream,
                        ),
                      ),
                    ),
                    Semantics(
                      liveRegion: true,
                      label: '$name ${scores[i]}',
                      child: ExcludeSemantics(
                        child: Text(
                          '${scores[i]}',
                          style: stoneNumerals(TypeScale.headline * 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.lg),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: inputs[i],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: l.sportPoints,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _add(i),
                      ),
                    ),
                    IconButton(
                      tooltip: l.sportAddPoints(name),
                      onPressed: () => _add(i),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        TextButton(
          onPressed: () => setState(() => scores = _fresh()),
          child: Text(l.appearanceReset),
        ),
      ],
    );
  }
}
