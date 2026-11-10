import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/card_pack_labels.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/stepper_row.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef StartSession = RulesIssue? Function({
  required GameTemplate template,
  required PackRules rules,
  required List<PoolDeck> pool,
  required List<String> names,
  required bool free,
});

class PackSetupView extends StatefulWidget {
  const PackSetupView({
    super.key,
    required this.templates,
    required this.onStart,
  });

  final List<GameTemplate> templates;
  final StartSession onStart;

  @override
  State<PackSetupView> createState() => _PackSetupViewState();
}

class _PackSetupViewState extends State<PackSetupView> {
  late GameTemplate template = widget.templates.first;
  final disabled = <String>{};
  bool free = false;
  PackRules rules = const PackRules();
  final names = [TextEditingController(), TextEditingController()];
  RulesIssue? issue;

  @override
  void dispose() {
    for (final n in names) {
      n.dispose();
    }
    super.dispose();
  }

  List<PoolDeck> get pool => [
    for (final c in template.creation)
      if (free || !disabled.contains(c.name))
        PoolDeck(name: c.name, cards: c.cards),
  ];

  void start() {
    final labels = [
      for (var i = 0; i < names.length; i++)
        names[i].text.trim().isEmpty
            ? context.l10n.cpPlayerName(i + 1)
            : names[i].text.trim(),
    ];
    final result = widget.onStart(
      template: template,
      rules: rules,
      pool: pool,
      names: labels,
      free: free,
    );
    setState(() => issue = result);
  }

  Widget deckSwitches() => Column(
    children: [
      SwitchListTile(
        title: Text(context.l10n.cpFreeMode),
        value: free,
        onChanged: (v) => setState(() => free = v),
      ),
      for (final c in template.creation)
        SwitchListTile(
          title: Text(context.l10n.cpDeckCount(c.name, c.cards.length)),
          value: free || !disabled.contains(c.name),
          onChanged: free
              ? null
              : (v) => setState(() {
                  v ? disabled.remove(c.name) : disabled.add(c.name);
                }),
        ),
    ],
  );

  Widget ruleSteppers() {
    final l = context.l10n;
    return Column(
      children: [
        StepperRow(
          label: l.cpCardsPerPack(rules.cardsPerPack),
          value: rules.cardsPerPack,
          min: 1,
          max: 12,
          onChanged: (v) =>
              setState(() => rules = rules.copyWith(cardsPerPack: v)),
        ),
        StepperRow(
          label: l.cpPacksPerPlayer(rules.packsPerPlayer),
          value: rules.packsPerPlayer,
          min: 1,
          max: 6,
          onChanged: (v) =>
              setState(() => rules = rules.copyWith(packsPerPlayer: v)),
        ),
        StepperRow(
          label: l.cpKeepMin(rules.keepMin),
          value: rules.keepMin,
          min: 0,
          max: rules.keepMax,
          onChanged: (v) => setState(() => rules = rules.copyWith(keepMin: v)),
        ),
        StepperRow(
          label: l.cpKeepMax(rules.keepMax),
          value: rules.keepMax,
          min: max(1, rules.keepMin),
          max: 24,
          onChanged: (v) => setState(() => rules = rules.copyWith(keepMax: v)),
        ),
        StepperRow(
          label: l.cpRerolls(rules.rerolls),
          value: rules.rerolls,
          min: 0,
          max: 6,
          onChanged: (v) => setState(() => rules = rules.copyWith(rerolls: v)),
        ),
        SwitchListTile(
          title: Text(l.cpDuplicates),
          value: rules.duplicates,
          onChanged: (v) =>
              setState(() => rules = rules.copyWith(duplicates: v)),
        ),
        SwitchListTile(
          title: Text(l.cpRevealLive),
          value: rules.reveal == RevealMode.live,
          onChanged: (v) => setState(
            () => rules = rules.copyWith(
              reveal: v ? RevealMode.live : RevealMode.hidden,
            ),
          ),
        ),
      ],
    );
  }

  Widget playerFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.cpPlayers,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      for (var i = 0; i < names.length; i++)
        Padding(
          padding: const EdgeInsets.only(top: Space.sm),
          child: TextField(
            controller: names[i],
            maxLength: 40,
            decoration: InputDecoration(
              labelText: context.l10n.cpPlayerName(i + 1),
              counterText: '',
            ),
          ),
        ),
      TextButton.icon(
        onPressed: names.length >= 12
            ? null
            : () => setState(() => names.add(TextEditingController())),
        icon: const Icon(Icons.person_add_alt),
        label: Text(context.l10n.cpAddPlayer),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DropdownButtonFormField<GameTemplate>(
        initialValue: template,
        isExpanded: true,
        decoration: InputDecoration(labelText: context.l10n.cpTemplate),
        items: [
          for (final t in widget.templates)
            DropdownMenuItem(value: t, child: Text(t.name)),
        ],
        onChanged: (t) => setState(() {
          template = t ?? template;
          disabled.clear();
        }),
      ),
      deckSwitches(),
      ruleSteppers(),
      const SizedBox(height: Space.md),
      playerFields(),
      if (issue != null)
        Padding(
          padding: const EdgeInsets.only(top: Space.md),
          child: Text(
            context.issueLabel(issue!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: Space.lg),
      FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(Targets.minimum),
        ),
        onPressed: start,
        child: Text(context.l10n.cpStart),
      ),
    ],
  );
}
