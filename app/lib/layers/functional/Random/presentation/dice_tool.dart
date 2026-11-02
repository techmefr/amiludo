import 'package:flutter/material.dart';

import '../../../technical/Theme/deck_widgets.dart';
import '../domain/random_tools.dart';

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
      final values = symbols.text
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context),
        values = symbols.text
            .split(',')
            .map((v) => v.trim())
            .where((v) => v.isNotEmpty)
            .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'Les dés sont jetés', 'Roll the dice'),
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<int>(
                initialValue: faces,
                decoration: const InputDecoration(labelText: 'Faces'),
                items: [4, 6, 8, 10, 12, 20, 100]
                    .map((n) => DropdownMenuItem(value: n, child: Text('d$n')))
                    .toList(),
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
                initialValue: count,
                decoration: InputDecoration(
                  labelText: tr(context, 'Nombre', 'Count'),
                ),
                items: List.generate(
                  12,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                ),
                onChanged: (n) => setState(() {
                  count = n!;
                  rolls = [];
                  locked = {};
                }),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(tr(context, 'Faces à symboles', 'Custom symbols')),
          value: custom,
          onChanged: (v) => setState(() {
            custom = v;
            rolls = [];
            locked = {};
          }),
        ),
        if (custom)
          TextField(
            controller: symbols,
            decoration: InputDecoration(
              labelText: tr(
                context,
                'Symboles séparés par des virgules',
                'Comma-separated symbols',
              ),
            ),
            onChanged: (_) => setState(() {
              rolls = [];
              locked = {};
            }),
          ),
        const SizedBox(height: 24),
        if (rolls.isEmpty)
          Text(
            tr(
              context,
              'Touchez le bouton pour lancer.',
              'Press the button to roll.',
            ),
          ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < rolls.length; i++)
              ChoiceChip(
                selected: locked.contains(i),
                showCheckmark: false,
                label: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '${custom && values.length >= rolls[i] ? values[rolls[i] - 1] : rolls[i]}${locked.contains(i) ? ' ▣' : ''}',
                    style: TextStyle(
                      fontFamily: 'ChakraPetch',
                      fontSize: custom ? 20 : 36,
                    ),
                  ),
                ),
                onSelected: (v) =>
                    setState(() => v ? locked.add(i) : locked.remove(i)),
              ),
          ],
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
          label: Text(tr(context, 'Lancer les dés', 'Roll dice')),
        ),
        const SizedBox(height: 12),
        Text(
          tr(
            context,
            'Touchez un dé pour le conserver au prochain lancer.',
            'Tap a die to keep it on the next roll.',
          ),
          style: theme.textTheme.bodySmall,
        ),
        const Divider(height: 40),
        TextField(
          controller: expression,
          decoration: InputDecoration(
            labelText: tr(
              context,
              'Expression : 2d6+3, d20, 4d8-2',
              'Expression: 2d6+3, d20, 4d8-2',
            ),
            suffixIcon: IconButton(
              tooltip: tr(context, 'Évaluer', 'Evaluate'),
              icon: const DeckIcon(Icons.play_arrow),
              onPressed: () {
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
              },
            ),
          ),
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            tr(context, 'DERNIERS LANCERS', 'RECENT ROLLS'),
            style: theme.textTheme.labelSmall,
          ),
          for (final h in history.take(8))
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(h)),
        ],
      ],
    );
  }
}
