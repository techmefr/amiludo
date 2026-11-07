import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _presets = ['1d4', '1d6', '1d8', '1d10', '1d12', '1d20', '1d100', '2d6'];

String describeRoll(String expression, DiceExpression roll) {
  final modifier = roll.modifier == 0
      ? ''
      : ' ${roll.modifier > 0 ? '+' : '-'}${roll.modifier.abs()}';
  return '$expression → ${roll.rolls.join(' + ')}$modifier = ${roll.total}';
}

Future<String?> showDiceSheet(BuildContext context, {RandomTools? random}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DiceSheet(random: random ?? RandomTools()),
    );

class DiceSheet extends StatefulWidget {
  const DiceSheet({super.key, required this.random});
  final RandomTools random;

  @override
  State<DiceSheet> createState() => _DiceSheetState();
}

class _DiceSheetState extends State<DiceSheet> {
  final expression = TextEditingController(text: '1d20');
  String? result;
  var invalid = false;

  @override
  void dispose() {
    expression.dispose();
    super.dispose();
  }

  void roll() {
    final text = expression.text.trim();
    try {
      final rolled = widget.random.evaluate(text);
      setState(() {
        result = describeRoll(text, rolled);
        invalid = false;
      });
    } on FormatException {
      setState(() => invalid = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.notebookToolDice, style: theme.textTheme.titleLarge),
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              children: [
                for (final p in _presets)
                  ActionChip(
                    label: Text(p),
                    onPressed: () {
                      expression.text = p;
                      roll();
                    },
                  ),
              ],
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: expression,
              onSubmitted: (_) => roll(),
              decoration: InputDecoration(
                labelText: l.notebookDiceExpression,
                errorText: invalid ? l.notebookDiceInvalid : null,
              ),
            ),
            const SizedBox(height: Space.md),
            FilledButton.tonal(onPressed: roll, child: Text(l.notebookRoll)),
            if (result != null) ...[
              const SizedBox(height: Space.lg),
              Text(result!, style: theme.textTheme.titleMedium),
              const SizedBox(height: Space.md),
              FilledButton(
                onPressed: () => Navigator.pop(context, result),
                child: Text(l.notebookAddToJournal),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
