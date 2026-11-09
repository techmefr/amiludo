import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/steampunk_face.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_face.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';

enum CardSkin { tarot, steampunk }

class CardSkinFace extends StatelessWidget {
  const CardSkinFace({
    super.key,
    required this.title,
    this.skin = CardSkin.tarot,
    this.number,
    this.description,
    this.art,
    this.style = TarotStyle.nightGold,
    this.width = 160,
  });
  final String title;
  final CardSkin skin;
  final int? number;
  final String? description;
  final Widget? art;
  final TarotStyle style;
  final double width;

  @override
  Widget build(BuildContext context) => switch (skin) {
    CardSkin.tarot => TarotFace(
      title: title,
      number: number,
      description: description,
      art: art,
      style: style,
      width: width,
    ),
    CardSkin.steampunk => SteampunkFace(
      title: title,
      description: description,
      art: art,
      width: width,
    ),
  };
}
