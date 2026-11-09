import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/league.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class LeagueTool extends StatefulWidget {
  const LeagueTool({super.key, required this.names});
  final List<String> names;

  @override
  State<LeagueTool> createState() => _LeagueToolState();
}

class _LeagueToolState extends State<LeagueTool> {
  final List<LeagueMatch> matches = [];
  final home = TextEditingController(), away = TextEditingController();
  int homeIndex = 0, awayIndex = 1;

  @override
  void dispose() {
    home.dispose();
    away.dispose();
    super.dispose();
  }

  void _add() {
    final a = int.tryParse(home.text.trim()), b = int.tryParse(away.text.trim());
    if (a == null || b == null || homeIndex == awayIndex) return;
    home.clear();
    away.clear();
    setState(() => matches.add(LeagueMatch(homeIndex, awayIndex, a, b)));
  }

  Widget _picker(int value, ValueChanged<int> onChanged) =>
      DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        items: [
          for (final (i, name) in widget.names.indexed)
            DropdownMenuItem(value: i, child: Text(name)),
        ],
        onChanged: (v) => onChanged(v ?? value),
      );

  Widget _score(TextEditingController controller) => SizedBox(
    width: 64,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final table = standings(widget.names.length, matches);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _picker(homeIndex, (v) => setState(() => homeIndex = v)),
            ),
            const SizedBox(width: Space.sm),
            _score(home),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Space.xs),
              child: Text('–'),
            ),
            _score(away),
            const SizedBox(width: Space.sm),
            Expanded(
              child: _picker(awayIndex, (v) => setState(() => awayIndex = v)),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Align(
          child: FilledButton.icon(
            onPressed: _add,
            icon: const DeckIcon(Icons.add),
            label: Text(l.leagueAddMatch),
          ),
        ),
        const SizedBox(height: Space.xl),
        Text(l.leagueTable, style: theme.titleLarge),
        for (final (rank, s) in table.indexed)
          Semantics(
            container: true,
            label: l.leagueRow(
              rank + 1,
              widget.names[s.player],
              s.points,
              s.played,
            ),
            child: ExcludeSemantics(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${rank + 1}')),
                title: Text(widget.names[s.player]),
                subtitle: Text('${s.wins}-${s.draws}-${s.losses}'),
                trailing: Text(
                  '${s.points}',
                  style: theme.headlineSmall?.copyWith(
                    fontFeatures: Numerals.tabular,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: Space.lg),
        for (final (i, m) in matches.indexed.toList().reversed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${widget.names[m.home]} ${m.homeScore} – ${m.awayScore} ${widget.names[m.away]}',
            ),
            trailing: IconButton(
              tooltip: l.leagueRemoveMatch,
              onPressed: () => setState(() => matches.removeAt(i)),
              icon: const DeckIcon(Icons.close),
            ),
          ),
      ],
    );
  }
}
