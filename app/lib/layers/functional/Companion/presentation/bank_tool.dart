import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/bank_ledger.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/stone_slab.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class BankTool extends StatefulWidget {
  const BankTool({super.key, required this.names});
  final List<String> names;

  @override
  State<BankTool> createState() => _BankToolState();
}

class _BankToolState extends State<BankTool> {
  late BankLedger ledger = BankLedger.begin(widget.names.length);
  final List<BankLedger> history = [];
  final amount = TextEditingController();
  int from = bankIndex, to = 0;
  final tool = toolThemeFor('bank');

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  int get value => int.tryParse(amount.text.trim()) ?? 0;

  void _transfer() {
    final next = ledger.transfer(from, to, value);
    if (identical(next, ledger)) return;
    tool.signal();
    amount.clear();
    setState(() {
      history.add(ledger);
      ledger = next;
    });
  }

  DropdownButtonFormField<int> _picker(
    String label,
    int selected,
    ValueChanged<int> onChanged,
  ) => DropdownButtonFormField<int>(
    initialValue: selected,
    decoration: InputDecoration(labelText: label),
    items: [
      DropdownMenuItem(value: bankIndex, child: Text(context.l10n.bankName)),
      for (final (i, name) in widget.names.indexed)
        DropdownMenuItem(value: i, child: Text(name)),
    ],
    onChanged: (v) => onChanged(v ?? selected),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, name) in widget.names.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: StoneSlab(
              accent: tool.accent,
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: theme.titleMedium?.copyWith(
                          color: StonePalette.cream,
                        ),
                      ),
                    ),
                    Semantics(
                      label: '$name ${ledger.balances[i]}',
                      child: ExcludeSemantics(
                        child: Text(
                          '${ledger.balances[i]}',
                          style: stoneNumerals(TypeScale.headline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: Space.lg),
        _picker(l.bankFrom, from, (v) => setState(() => from = v)),
        const SizedBox(height: Space.md),
        _picker(l.bankTo, to, (v) => setState(() => to = v)),
        const SizedBox(height: Space.md),
        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l.bankAmount),
          onSubmitted: (_) => _transfer(),
        ),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.sm,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _transfer,
              icon: const DeckIcon(Icons.arrow_forward),
              label: Text(l.bankTransfer),
            ),
            TextButton.icon(
              onPressed: history.isEmpty
                  ? null
                  : () => setState(() => ledger = history.removeLast()),
              icon: const DeckIcon(Icons.undo),
              label: Text(l.gameUndo),
            ),
          ],
        ),
      ],
    );
  }
}
