import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SheetSummaryCard extends StatelessWidget {
  const SheetSummaryCard({super.key, required this.sheet});
  final CharacterSheet sheet;

  static const _headline = ['age', 'job', 'origin'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final facts = [
      for (final id in _headline)
        if (sheet.first(id).isNotEmpty) sheet.first(id),
    ];
    final traits = sheet.of('qualities').take(2).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.sheetTitle, style: theme.textTheme.labelLarge),
        if (sheet.of('nickname').isNotEmpty)
          Text(
            '« ${sheet.first('nickname')} »',
            style: theme.textTheme.titleSmall,
          ),
        if (facts.isNotEmpty) Text(facts.join(' · ')),
        if (traits.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Space.xs),
            child: Text(traits.join(' · '), style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}
