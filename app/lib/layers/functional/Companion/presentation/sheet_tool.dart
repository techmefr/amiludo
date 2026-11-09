import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/ranking.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/score_presets.dart';
import 'package:amiludo/layers/functional/Companion/presentation/ranking_podium.dart';
import 'package:amiludo/layers/functional/Companion/presentation/sheet_grid.dart';
import 'package:amiludo/layers/functional/Companion/presentation/sheet_labels.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _startRounds = 5;

class SheetTool extends StatefulWidget {
  const SheetTool({super.key, required this.names});
  final List<String> names;

  @override
  State<SheetTool> createState() => _SheetToolState();
}

class _SheetToolState extends State<SheetTool> {
  ScorePreset preset = scorePresets.first;
  int rounds = _startRounds;
  int epoch = 0;
  final Map<String, TextEditingController> fields = {};

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  int get rowCount => preset.rounds ? rounds : preset.rows.length;

  TextEditingController _field(int row, int player) =>
      fields.putIfAbsent('$epoch:$row:$player', TextEditingController.new);

  List<int> _values(int player) => [
    for (var r = 0; r < rowCount; r++)
      int.tryParse(_field(r, player).text.trim()) ?? 0,
  ];

  bool get hasInput => [
    for (var r = 0; r < rowCount; r++)
      for (var p = 0; p < widget.names.length; p++) _field(r, p).text,
  ].any((text) => text.trim().isNotEmpty);

  void _choose(ScorePreset next) => setState(() {
    preset = next;
    rounds = _startRounds;
    epoch++;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final count = widget.names.length;
    final totals = [
      for (var p = 0; p < count; p++) sheetTotal(preset, _values(p)),
    ];
    final lines = [
      for (var r = 0; r < rowCount; r++)
        SheetLine(
          label: preset.rounds
              ? l.sheetRound(r + 1)
              : sheetRowLabel(l, preset.rows[r].id),
          fields: [for (var p = 0; p < count; p++) _field(r, p)],
        ),
      if (preset.hasBonus)
        SheetLine(
          label: l.sheetBonus(preset.bonusThreshold),
          readings: [
            for (var p = 0; p < count; p++) '${sheetBonus(preset, _values(p))}',
          ],
        ),
      SheetLine(
        label: l.sheetTotal,
        readings: [for (final total in totals) '$total'],
        emphasis: true,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Space.sm,
            children: [
              for (final option in scorePresets)
                ChoiceChip(
                  label: Text(sheetPresetLabel(l, option.id)),
                  selected: option.id == preset.id,
                  onSelected: (_) => _choose(option),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          SheetGrid(
            players: widget.names,
            lines: lines,
            onChanged: () => setState(() {}),
          ),
          if (preset.rounds)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => rounds++),
                icon: const DeckIcon(Icons.add),
                label: Text(l.sheetAddRound),
              ),
            ),
          const SizedBox(height: Space.lg),
          if (hasInput)
            RankingPodium(
              ranking: rankPlayers(
                widget.names,
                totals,
                lowestWins: preset.lowestWins,
              ),
            ),
        ],
      ),
    );
  }
}
