import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class DiceTool extends StatefulWidget {
  const DiceTool({super.key});
  @override
  State<DiceTool> createState() => _DiceToolState();
}

class _DiceToolState extends State<DiceTool> {
  final random = RandomTools();
  final expression = TextEditingController(text: '2d6+3'),
      symbols = TextEditingController(
        text: 'Étoile, Lune, Soleil, Éclair, Feuille, Feu',
      );
  int faces = 6, count = 2;
  List<int> rolls = [];
  Set<int> locked = {};
  final List<String> history = [];
  bool custom = false;
  @override
  void dispose() {
    expression.dispose();
    symbols.dispose();
    super.dispose();
  }

  void roll() {
    setState(() {
      final values = symbolValues();
      if (custom && values.length < 2) {
        notify(context, 'Ajoutez au moins deux symboles.');
        return;
      }
      rolls = random.dice(
        custom ? values.length : faces,
        count,
        locked: locked,
        previous: rolls,
      );
      history.insert(
        0,
        custom
            ? rolls.map((v) => values[v - 1]).join(' / ')
            : '${rolls.join(' · ')} = ${rolls.fold(0, (a, b) => a + b)}',
      );
      if (history.length > 20) history.removeLast();
    });
  }

  List<String> symbolValues() => symbols.text
      .split(',')
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .toList();

  void evaluate() {
    try {
      final result = random.evaluate(expression.text);
      setState(
        () => history.insert(
          0,
          '${expression.text} → ${result.rolls.join(', ')} → ${result.total}',
        ),
      );
    } on ArgumentError catch (e) {
      notify(context, e.message.toString());
    } on FormatException catch (e) {
      notify(context, e.message);
    }
  }

  Widget dieSettings() => Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      SizedBox(
        width: 150,
        child: DropdownButtonFormField<int>(
          style: Theme.of(context).textTheme.bodyLarge,
          initialValue: faces,
          decoration: const InputDecoration(labelText: 'Faces'),
          items: [
            4,
            6,
            8,
            10,
            12,
            20,
            100,
          ].map((n) => DropdownMenuItem(value: n, child: Text('d$n'))).toList(),
          onChanged: (n) => setState(() {
            faces = n!;
            rolls = [];
            locked = {};
          }),
        ),
      ),
      SizedBox(
        width: 150,
        child: DropdownButtonFormField<int>(
          style: Theme.of(context).textTheme.bodyLarge,
          initialValue: count,
          decoration: InputDecoration(labelText: context.l10n.randomCount),
          items: List.generate(
            12,
            (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
          ),
          onChanged: (n) => setState(() {
            count = n!;
            rolls = [];
            locked = {};
          }),
        ),
      ),
    ],
  );

  Widget symbolsField() => TextField(
    controller: symbols,
    decoration: InputDecoration(
      labelText: context.l10n.randomCommaSeparatedSymbols,
    ),
    onChanged: (_) => setState(() {
      rolls = [];
      locked = {};
    }),
  );

  Widget die(List<String> values, int i) => ChoiceChip(
    selected: locked.contains(i),
    showCheckmark: false,
    label: !custom
        ? DieResult(value: rolls[i], locked: locked.contains(i))
        : Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${custom && values.length >= rolls[i] ? values[rolls[i] - 1] : rolls[i]}${locked.contains(i) ? ' ▣' : ''}',
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                fontSize: custom ? 20 : 36,
              ),
            ),
          ),
    onSelected: (v) => setState(() => v ? locked.add(i) : locked.remove(i)),
  );

  Widget expressionField() => TextField(
    controller: expression,
    decoration: InputDecoration(
      labelText: context.l10n.randomExpression2d63D204d8,
      suffixIcon: IconButton(
        tooltip: context.l10n.randomEvaluate,
        icon: const DeckIcon(Icons.play_arrow),
        onPressed: evaluate,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), values = symbolValues();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.randomRollTheDice,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        dieSettings(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.randomCustomSymbols),
          value: custom,
          onChanged: (v) => setState(() {
            custom = v;
            rolls = [];
            locked = {};
          }),
        ),
        if (custom) symbolsField(),
        const SizedBox(height: 24),
        if (rolls.isEmpty) Text(context.l10n.randomPressTheButtonToRoll),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (var i = 0; i < rolls.length; i++) die(values, i)],
        ),
        if (rolls.isNotEmpty && !custom)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'TOTAL / ${rolls.fold(0, (a, b) => a + b)}',
              style: theme.textTheme.titleLarge,
            ),
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: roll,
          icon: const DeckIcon(Icons.casino_outlined),
          label: Text(context.l10n.randomRollDice),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.randomTapADieToKeep,
          style: theme.textTheme.bodySmall,
        ),
        const Divider(height: 40),
        expressionField(),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            context.l10n.randomRecentRolls,
            style: theme.textTheme.labelSmall,
          ),
          for (final h in history.take(8))
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(h)),
        ],
      ],
    );
  }
}
