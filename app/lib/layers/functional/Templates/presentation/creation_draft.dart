import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

class CardDraft {
  CardDraft(CharacterCard? c)
    : name = TextEditingController(text: c?.name ?? ''),
      description = TextEditingController(text: c?.description ?? '');
  final TextEditingController name, description;
  CharacterCard value() => CharacterCard.fromJson({
    'name': name.text.trim(),
    'description': description.text.trim(),
  });
  void dispose() {
    name.dispose();
    description.dispose();
  }
}

class CreationDraft {
  CreationDraft(CreationCategory? c)
    : name = TextEditingController(text: c?.name ?? ''),
      draw = TextEditingController(text: '${c?.draw ?? 3}'),
      keepMin = TextEditingController(text: '${c?.keepMin ?? 1}'),
      keepMax = TextEditingController(text: '${c?.keepMax ?? 1}'),
      cards =
          c?.cards.map(CardDraft.new).toList() ??
          [CardDraft(null), CardDraft(null), CardDraft(null)];
  final TextEditingController name, draw, keepMin, keepMax;
  final List<CardDraft> cards;
  CreationCategory value() => CreationCategory.fromJson({
    'name': name.text.trim(),
    'draw': int.parse(draw.text),
    'keepMin': int.parse(keepMin.text),
    'keepMax': int.parse(keepMax.text),
    'cards': cards.map((c) => c.value().toJson()).toList(),
  });
  void dispose() {
    name.dispose();
    draw.dispose();
    keepMin.dispose();
    keepMax.dispose();
    for (final c in cards) {
      c.dispose();
    }
  }
}
