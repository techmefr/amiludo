import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/journal.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/oracle.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/oracle_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef OracleResult = ({JournalKind kind, String label, String text});

class OraclePanel extends StatefulWidget {
  const OraclePanel({
    super.key,
    required this.chaos,
    required this.onChaos,
    required this.onPush,
    this.oracleFor,
  });

  final int chaos;
  final ValueChanged<int> onChaos;
  final void Function(JournalKind kind, String text) onPush;
  final Oracle Function(OracleTables tables)? oracleFor;

  @override
  State<OraclePanel> createState() => _OraclePanelState();
}

class _OraclePanelState extends State<OraclePanel> {
  Oracle? oracle;
  var likelihood = Likelihood.even;
  final results = <OracleResult>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    loadOracleTables(DefaultAssetBundle.of(context), language).then((tables) {
      if (mounted) {
        setState(
          () => oracle = widget.oracleFor?.call(tables) ?? Oracle(tables),
        );
      }
    });
  }

  void add(JournalKind kind, String label, String text) => setState(() {
    results.insert(0, (kind: kind, label: label, text: text));
    if (results.length > 8) results.removeLast();
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final o = oracle;
    if (o == null) return const SizedBox.shrink();
    final actions = <(String, VoidCallback)>[
      (
        l.notebookAsk,
        () {
          final answer = o.ask(likelihood, widget.chaos);
          add(
            JournalKind.oracle,
            l.notebookOracleQuestion,
            context.answerText(likelihood, answer),
          );
        },
      ),
      (
        l.notebookSceneCheck,
        () => add(
          JournalKind.scene,
          l.notebookSceneCheck,
          context.sceneText(o.sceneCheck(widget.chaos)),
        ),
      ),
      (
        l.notebookMeaning,
        () => add(JournalKind.oracle, l.notebookMeaning, o.meaning()),
      ),
      (
        l.notebookDescriptors,
        () => add(JournalKind.oracle, l.notebookDescriptors, o.descriptors()),
      ),
      (
        l.notebookRandomEvent,
        () => add(JournalKind.oracle, l.notebookRandomEvent, o.randomEvent()),
      ),
      (
        l.notebookReaction,
        () => add(JournalKind.oracle, l.notebookReaction, o.reaction()),
      ),
      (
        l.notebookDiscovery,
        () => add(JournalKind.oracle, l.notebookDiscovery, o.discovery()),
      ),
      (
        l.notebookComplication,
        () => add(JournalKind.oracle, l.notebookComplication, o.complication()),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.notebookLikelihood,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          children: [
            for (final value in Likelihood.values)
              ChoiceChip(
                label: Text(context.likelihoodLabel(value)),
                selected: likelihood == value,
                onSelected: (_) => setState(() => likelihood = value),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        Text(
          l.notebookChaos(widget.chaos),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: widget.chaos.toDouble(),
          min: 1,
          max: 9,
          divisions: 8,
          label: '${widget.chaos}',
          onChanged: (v) => widget.onChaos(v.round()),
        ),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final (label, run) in actions)
              FilledButton.tonal(onPressed: run, child: Text(label)),
          ],
        ),
        const SizedBox(height: Space.lg),
        for (final r in results)
          Card(
            child: ListTile(
              title: Text(r.text),
              subtitle: Text(r.label),
              trailing: IconButton(
                tooltip: l.notebookAddToJournal,
                constraints: const BoxConstraints(
                  minWidth: Targets.minimum,
                  minHeight: Targets.minimum,
                ),
                icon: const Icon(Icons.playlist_add),
                onPressed: () => widget.onPush(r.kind, r.text),
              ),
            ),
          ),
      ],
    );
  }
}
