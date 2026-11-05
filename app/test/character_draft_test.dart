import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/character_draft_slot.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/card_face.dart';
import 'package:amiludo/layers/functional/Random/presentation/pack_opening.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/pack_catalog.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';

void main() {
  final packs = PackCatalog.decode(
    File('assets/community/catalog.json').readAsStringSync(),
  );
  final pack = packs.firstWhere((p) => p.id == 'example-booster');

  group('draft persistence', () {
    test('restores the same offers, index and choices', () {
      final d = CharacterDraft(
        pack.creation,
        packName: pack.name,
        random: RandomTools(random: Random(5)),
      )..choose({0, 1});
      final restored = CharacterDraft.fromJson(
        jsonDecode(jsonEncode(d.toJson())) as Map<String, dynamic>,
      );
      expect(restored.packName, pack.name);
      expect(restored.index, 1);
      expect(
        restored.offers.map((o) => o.map((c) => c.name).toList()).toList(),
        d.offers.map((o) => o.map((c) => c.name).toList()).toList(),
      );
      expect(restored.choices.keys, d.choices.keys);
      restored.choose({0});
      expect(restored.index, 2);
    });

    test('rejects an inconsistent stored draft', () {
      final d = CharacterDraft(pack.creation, packName: pack.name);
      final broken = {...d.toJson(), 'index': 2};
      expect(() => CharacterDraft.fromJson(broken), throwsFormatException);
    });

    test('an empty slot stays empty after a round trip', () {
      final slot = CharacterDraftSlot.fromJson(
        const CharacterDraftSlot().toJson(),
      );
      expect(slot.draft, isNull);
    });
  });

  group('card images', () {
    test('keeps a valid reference through export and import', () {
      final card = CharacterCard.fromJson({
        'name': 'Duneen',
        'image': 'cards/race-duneens',
      });
      expect(card.image, 'cards/race-duneens');
      expect(CharacterCard.fromJson(card.toJson()).image, 'cards/race-duneens');
    });

    test('drops only an invalid reference', () {
      for (final bad in [
        '../secret',
        'https://example.com/a.png',
        'cards/A B',
      ]) {
        final card = CharacterCard.fromJson({'name': 'X', 'image': bad});
        expect(card.image, isNull);
        expect(card.name, 'X');
      }
    });
  });

  group('rendering', () {
    Widget host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

    testWidgets('a missing image falls back to the type icon', (tester) async {
      await tester.pumpWidget(
        host(
          const CardFace(
            card: CharacterCard(name: 'Duneen', image: 'cards/missing'),
            type: 'Race',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(DeckIcon), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion reveals every card immediately', (
      tester,
    ) async {
      final chosen = <int>{};
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: host(
            PackReveal(
              type: 'Race',
              cards: const [
                CharacterCard(name: 'A'),
                CharacterCard(name: 'B'),
                CharacterCard(name: 'C'),
              ],
              selected: chosen,
              keepMax: 1,
              onToggle: chosen.add,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Reveal all'), findsNothing);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('the reveal can be skipped and cards become selectable', (
      tester,
    ) async {
      final chosen = <int>{};
      await tester.pumpWidget(
        host(
          PackReveal(
            type: 'Race',
            cards: const [
              CharacterCard(name: 'A'),
              CharacterCard(name: 'B'),
            ],
            selected: chosen,
            keepMax: 1,
            onToggle: chosen.add,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Reveal all'), findsOneWidget);
      await tester.tap(find.text('Reveal all'));
      await tester.pump();
      await tester.tap(find.text('B'));
      expect(chosen, {1});
    });
  });
}
