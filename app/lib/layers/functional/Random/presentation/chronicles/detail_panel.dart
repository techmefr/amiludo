import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/card_painter.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/table_gestures.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ChroniclesDetail extends StatelessWidget {
  const ChroniclesDetail({
    super.key,
    required this.card,
    required this.data,
  });
  final ChroniclesCard card;
  final ChroniclesData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rarity = data.rarity(card.rarity);
    final mods = [
      for (final s in data.stats)
        if ((card.modifiers[s.id] ?? 0) != 0)
          '${s.name} ${card.modifiers[s.id]! > 0 ? '+' : ''}'
              '${card.modifiers[s.id]}',
    ];
    return Padding(
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data.labelOf(card)} · ${rarity.name}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: rarityColor(rarity.score),
            ),
          ),
          Text(card.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Space.md),
          Text(card.text),
          if (mods.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            Text(mods.join(' · ')),
          ],
          const SizedBox(height: Space.lg),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey('close-detail'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.chroniclesClose),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showChroniclesDetail(
  BuildContext context,
  ChroniclesCard card,
  ChroniclesData data,
) {
  final panel = ChroniclesDetail(card: card, data: data);
  if (MediaQuery.sizeOf(context).width < phoneWidth) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(child: panel),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: panel,
      ),
    ),
  );
}
