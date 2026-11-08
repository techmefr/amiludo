import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/card_deck.dart';
import 'package:amiludo/layers/technical/Theme/components/playing_card.dart';

class DeckFace extends StatelessWidget {
  const DeckFace({super.key, required this.card, required this.width});
  final String card;
  final double width;

  @override
  Widget build(BuildContext context) {
    final face = PlayingFace.tryParse(card);
    return Semantics(
      label: card,
      excludeSemantics: true,
      child: face == null
          ? PlayingCard(label: card, width: width)
          : PlayingCard(
              rank: face.rank,
              suit: face.suit,
              red: face.red,
              width: width,
            ),
    );
  }
}
