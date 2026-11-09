import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/ranking.dart';
import 'package:amiludo/layers/functional/Companion/presentation/ranking_podium.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class RankingTool extends StatefulWidget {
  const RankingTool({super.key, required this.names});
  final List<String> names;

  @override
  State<RankingTool> createState() => _RankingToolState();
}

class _RankingToolState extends State<RankingTool> {
  late final List<TextEditingController> fields = [
    for (final _ in widget.names) TextEditingController(),
  ];
  bool lowestWins = false;

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  List<RankedPlayer> get ranking => rankPlayers(widget.names, [
    for (final f in fields) num.tryParse(f.text.trim().replaceAll(',', '.')),
  ], lowestWins: lowestWins);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, name) in widget.names.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.md),
              child: TextField(
                controller: fields[i],
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[-0-9.,]')),
                ],
                decoration: InputDecoration(labelText: l.rankingScoreFor(name)),
                onChanged: (_) => setState(() {}),
              ),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.rankingLowestWins),
            value: lowestWins,
            onChanged: (value) => setState(() => lowestWins = value),
          ),
          const SizedBox(height: Space.lg),
          RankingPodium(ranking: ranking),
        ],
      ),
    );
  }
}
