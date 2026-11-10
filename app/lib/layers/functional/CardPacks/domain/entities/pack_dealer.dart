import 'dart:math';

import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_rarity.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/player_packs.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

abstract final class PackDealer {
  static Random _random(int seed, int player, int deck, int pack, int round) =>
      Random(Object.hash(seed, player, deck, pack, round));

  static List<DealtCard> _dealt(Random random, List<CharacterCard> cards) => [
    for (final c in cards) DealtCard(c, CardRarity.roll(random)),
  ];

  static List<CharacterCard> _shuffle(Random random, List<CharacterCard> from) =>
      [...from]..shuffle(random);

  static PlayerPacks deal({
    required String name,
    required int index,
    required int seed,
    required List<PoolDeck> pool,
    required PackRules rules,
  }) {
    final packs = <SealedPack>[];
    for (var d = 0; d < pool.length; d++) {
      final random = _random(seed, index, d, 0, 0);
      final order = _shuffle(random, pool[d].cards);
      for (var p = 0; p < rules.packsPerPlayer; p++) {
        final cards = rules.duplicates
            ? _shuffle(random, pool[d].cards).take(rules.cardsPerPack)
            : order.skip(p * rules.cardsPerPack).take(rules.cardsPerPack);
        packs.add(
          SealedPack(
            category: pool[d].name,
            cards: _dealt(random, cards.toList()),
          ),
        );
      }
    }
    return PlayerPacks(name: name, packs: packs);
  }

  static PlayerPacks reroll({
    required PlayerPacks player,
    required int index,
    required int seed,
    required int pack,
    required List<PoolDeck> pool,
    required PackRules rules,
  }) {
    final current = player.packs[pack];
    if (current.rerollsUsed >= rules.rerolls || player.validated) return player;
    final deck = pool.firstWhere((d) => d.name == current.category);
    final others = {
      for (var i = 0; i < player.packs.length; i++)
        if (i != pack && player.packs[i].category == current.category)
          for (final c in player.packs[i].cards) c.card.name,
    };
    final fresh = [
      for (final c in deck.cards)
        if (rules.duplicates || !others.contains(c.name)) c,
    ];
    final round = current.rerollsUsed + 1;
    final random = _random(seed, index, pack, pack, round);
    final next = _shuffle(random, fresh).take(rules.cardsPerPack).toList();
    final packs = [...player.packs];
    packs[pack] = current.copyWith(
      cards: _dealt(random, next),
      rerollsUsed: round,
      opened: false,
    );
    final prefix = '$pack.';
    return player.copyWith(
      packs: packs,
      kept: {...player.kept}..removeWhere((k) => k.startsWith(prefix)),
    );
  }
}
