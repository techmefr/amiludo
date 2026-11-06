import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

CharacterCard characterCardOf(ChroniclesCard card, {String prefix = ''}) =>
    CharacterCard(
      name: card.name,
      description: prefix.isEmpty ? card.text : '$prefix. ${card.text}',
    );

CharacterCard keptCharacterCard(KeptCard kept, String destinyLabel) =>
    characterCardOf(kept.card, prefix: kept.destiny ? destinyLabel : '');
