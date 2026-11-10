import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:amiludo/layers/technical/Theme/tokens/type_roles.dart';
import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<void> showRuleDecisions(
  BuildContext context, {
  required RuleGame game,
  required ValueChanged<RuleGame> onChanged,
  DateTime Function()? now,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => RuleDecisionsSheet(game: game, onChanged: onChanged, now: now),
);

class RuleDecisionsSheet extends StatefulWidget {
  const RuleDecisionsSheet({
    super.key,
    required this.game,
    required this.onChanged,
    this.now,
  });
  final RuleGame game;
  final ValueChanged<RuleGame> onChanged;
  final DateTime Function()? now;

  @override
  State<RuleDecisionsSheet> createState() => _RuleDecisionsSheetState();
}

class _RuleDecisionsSheetState extends State<RuleDecisionsSheet> {
  final question = TextEditingController();
  final ruling = TextEditingController();
  late RuleGame game = widget.game;
  String query = '';

  @override
  void dispose() {
    question.dispose();
    ruling.dispose();
    super.dispose();
  }

  void _commit(RuleGame next) {
    setState(() => game = next);
    widget.onChanged(next);
  }

  void _add() {
    final next = game.addDecision(
      question.text,
      ruling.text,
      (widget.now ?? DateTime.now)(),
    );
    if (identical(next, game)) return;
    question.clear();
    ruling.clear();
    _commit(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final shown = [
      for (final d in game.decisions)
        if (d.matches(query)) d,
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.rulesDecisionsTitle(game.name), style: TypeRoles.sectionTitle(context)),
          const SizedBox(height: Space.md),
          TextField(
            controller: question,
            decoration: InputDecoration(labelText: l.rulesDecisionQuestion),
          ),
          const SizedBox(height: Space.sm),
          TextField(
            controller: ruling,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: l.rulesDecisionRuling),
          ),
          const SizedBox(height: Space.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: _add,
              child: Text(l.rulesDecisionAdd),
            ),
          ),
          if (game.decisions.length > 3)
            TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                labelText: l.rulesSearch,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          if (game.decisions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Text(l.rulesDecisionsEmpty),
            ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final d in shown)
                  ListTile(
                    title: Text(d.question.isEmpty ? d.ruling : d.question),
                    subtitle: Text(
                      [
                        if (d.question.isNotEmpty) d.ruling,
                        DateFormat.yMMMd(locale).format(d.at.toLocal()),
                      ].join('\n'),
                    ),
                    isThreeLine: d.question.isNotEmpty,
                    trailing: IconButton(
                      tooltip: l.rulesDecisionDelete,
                      onPressed: () => _commit(game.removeDecision(d.id)),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
