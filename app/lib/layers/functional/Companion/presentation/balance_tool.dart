import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/team_balance.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class BalanceTool extends StatefulWidget {
  const BalanceTool({super.key, required this.names});
  final List<String> names;

  @override
  State<BalanceTool> createState() => _BalanceToolState();
}

class _BalanceToolState extends State<BalanceTool> {
  late final List<int> levels = [for (final _ in widget.names) 3];
  int teams = 2;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final groups = balanceTeams(levels, teams: teams);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, name) in widget.names.indexed)
          Row(
            children: [
              SizedBox(width: 96, child: Text(name)),
              Expanded(
                child: Slider(
                  value: levels[i].toDouble(),
                  min: minLevel.toDouble(),
                  max: maxLevel.toDouble(),
                  divisions: maxLevel - minLevel,
                  label: '${levels[i]}',
                  semanticFormatterCallback: (v) =>
                      l.balanceLevel(name, v.round()),
                  onChanged: (v) => setState(() => levels[i] = v.round()),
                ),
              ),
              Text('${levels[i]}'),
            ],
          ),
        Wrap(
          spacing: Space.sm,
          children: [
            for (final count in const [2, 3])
              ChoiceChip(
                label: Text(l.balanceTeams(count)),
                selected: teams == count,
                onSelected: (_) => setState(() => teams = count),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        for (final (t, group) in groups.indexed)
          Card(
            child: ListTile(
              title: Text(
                l.balanceTeamTotal(
                  t + 1,
                  group.fold<int>(0, (s, p) => s + levels[p]),
                ),
                style: theme.titleMedium,
              ),
              subtitle: Text(group.map((p) => widget.names[p]).join(' · ')),
            ),
          ),
      ],
    );
  }
}
