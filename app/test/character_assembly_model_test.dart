import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/appearance_item.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';

List<CreationCategory> categories() => [
  for (final n in ['trade', 'weapon'])
    CreationCategory(
      name: n,
      draw: 2,
      cards: [
        for (var i = 0; i < 4; i++)
          CharacterCard(name: '$n-$i', appearanceItemId: '$n-item-$i'),
      ],
    ),
];

CharacterDraft draft() =>
    CharacterDraft(categories(), random: RandomTools(random: Random(3)));

void main() {
  test('going back keeps the same offers and drops the later choice', () {
    final d = draft();
    final offers = d.offers[0].map((c) => c.name).toList();
    d.choose({0});
    d.back();
    expect(d.index, 0);
    expect(d.choices, isEmpty);
    expect(d.offers[0].map((c) => c.name).toList(), offers);
  });

  test('cannot go back from the first booster', () {
    expect(draft().canGoBack, isFalse);
    expect(() => draft().back(), throwsStateError);
  });

  test('appearance, version and card item ids survive a round trip', () {
    final d = draft()
      ..appearance['head'] = 'head-a'
      ..catalogueVersion = 2
      ..choose({0});
    final r = CharacterDraft.fromJson(
      jsonDecode(jsonEncode(d.toJson())) as Map<String, dynamic>,
    );
    expect(r.appearance['head'], 'head-a');
    expect(r.catalogueVersion, 2);
    expect(
      r.choices['trade']!.first.appearanceItemId,
      startsWith('trade-item'),
    );
  });

  test('a draft saved before appearance existed still loads', () {
    final json = draft().toJson()
      ..remove('appearance')
      ..remove('catalogueVersion');
    final r = CharacterDraft.fromJson(
      jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
    );
    expect(r.appearance, isEmpty);
    expect(r.catalogueVersion, 1);
  });

  test('appearance item fits only declared morphologies and peoples', () {
    final item = AppearanceItem.fromJson({
      'id': 'arm',
      'slot': 'prosthesis',
      'peoples': ['a'],
      'variants': {
        'slim': {
          'layers': [
            {'order': 4, 'src': 'avatar/implants/arm.png'},
          ],
          'hideBodyParts': ['left-arm'],
        },
      },
    });
    expect(item.fits('slim', 'a'), isTrue);
    expect(item.fits('broad', 'a'), isFalse);
    expect(item.fits('slim', 'b'), isFalse);
    expect(item.variants['slim']!.hideBodyParts, ['left-arm']);
    expect(AppearanceItem.fromJson(item.toJson()).id, 'arm');
  });
}
