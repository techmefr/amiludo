import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/player_packs.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/cubit/card_pack_cubit.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/rarity_card.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/sealed_pack_view.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({
    super.key,
    required this.session,
    required this.index,
    required this.cubit,
  });

  final CardPackSession session;
  final int index;
  final CardPackCubit cubit;

  PlayerPacks get player => session.players[index];

  Widget counters(BuildContext context) => Semantics(
    liveRegion: true,
    child: Wrap(
      spacing: Space.md,
      children: [
        for (final c in player.categories)
          Chip(
            label: Text(
              context.l10n.cpKeptCounter(
                c,
                player.keptIn(c),
                session.rules.keepMax,
              ),
            ),
          ),
      ],
    ),
  );

  Widget openedPack(BuildContext context, int p) {
    final pack = player.packs[p];
    final left = session.rules.rerolls - pack.rerollsUsed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(pack.category, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.md,
          runSpacing: Space.md,
          children: [
            for (var c = 0; c < pack.cards.length; c++)
              SizedBox(
                width: 150,
                child: RarityCard(
                  dealt: pack.cards[c],
                  category: pack.category,
                  number: c + 1,
                  kept: player.isKept(p, c),
                  onTap: () => cubit.toggle(index, p, c),
                ),
              ),
          ],
        ),
        if (left > 0)
          TextButton.icon(
            onPressed: () => cubit.reroll(index, p),
            icon: const Icon(Icons.casino_outlined),
            label: Text(context.l10n.cpReroll(left)),
          ),
      ],
    );
  }

  Widget validation(BuildContext context) {
    final ready = player.ready(session.rules);
    final hint = !player.allOpened
        ? context.l10n.cpOpenAllFirst
        : player.missing(session.rules) > 0
        ? context.l10n.cpMissing(player.missing(session.rules))
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Text(hint, textAlign: TextAlign.center),
          ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(Targets.minimum),
          ),
          onPressed: ready ? () => cubit.validate(index) : null,
          child: Text(context.l10n.cpValidate),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      counters(context),
      for (var p = 0; p < player.packs.length; p++) ...[
        const SizedBox(height: Space.lg),
        if (player.packs[p].opened)
          openedPack(context, p)
        else
          SealedPackView(
            key: ValueKey('pack-$index-$p-${player.packs[p].rerollsUsed}'),
            pack: player.packs[p],
            onOpened: () => cubit.open(index, p),
          ),
      ],
      const SizedBox(height: Space.xl),
      validation(context),
    ],
  );
}
