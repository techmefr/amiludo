import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.session});

  final CardPackSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = session.boardVisible(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!visible)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: Text(context.l10n.cpBoardHidden),
          ),
        for (final p in session.players)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.name, style: theme.textTheme.titleMedium),
                      ),
                      if (p.validated) const Icon(Icons.check_circle_outline),
                    ],
                  ),
                  Text(
                    context.l10n.cpBoardProgress(p.openedCount, p.packs.length),
                  ),
                  if (visible) Text(context.l10n.cpBoardKept(p.kept.length)),
                  if (visible)
                    for (final c in p.categories)
                      for (final d in p.keptCards(c))
                        Text('$c · ${d.card.name}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
