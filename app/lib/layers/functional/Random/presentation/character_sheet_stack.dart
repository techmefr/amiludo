import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/card_face.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';

class CharacterSheetStack extends StatelessWidget {
  const CharacterSheetStack({super.key, required this.choices});

  final Map<String, List<CharacterCard>> choices;

  @override
  Widget build(BuildContext context) => ResponsiveGrid(
    minimumWidth: 200,
    children: [
      for (final entry in choices.entries)
        for (final card in entry.value) CardFace(card: card, type: entry.key),
    ],
  );
}
