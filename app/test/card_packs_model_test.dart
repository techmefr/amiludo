import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_pack_session.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/card_rarity.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/use_cases/card_pack_use_cases.dart';
import 'package:amiludo/layers/functional/CardPacks/presentation/cubit/card_pack_cubit.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/character_pack.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

PoolDeck deck(String name, int n) => PoolDeck(
  name: name,
  cards: [for (var i = 0; i < n; i++) CharacterCard(name: '$name $i')],
);

final pool = [deck('Origin', 10), deck('Class', 8)];

CardPackSession start({
  PackRules rules = const PackRules(),
  List<String> names = const ['Ana', 'Bo'],
  int seed = 7,
}) => CardPackSession.start(
  id: 's',
  template: 'Demo',
  rules: rules,
  pool: pool,
  names: names,
  seed: seed,
  createdAt: 1,
);

void main() {
  group('rules', () {
    test('are checked against the pool and players', () {
      expect(const PackRules().check(pool, 2), isNull);
      expect(const PackRules().check(pool, 0), RulesIssue.noPlayers);
      expect(const PackRules().check(const [], 2), RulesIssue.noDecks);
      expect(
        const PackRules(cardsPerPack: 9).check(pool, 2),
        RulesIssue.poolTooSmall,
      );
      expect(
        const PackRules(cardsPerPack: 9, duplicates: true).check(pool, 2),
        RulesIssue.poolTooSmall,
      );
      expect(
        const PackRules(
          cardsPerPack: 6,
          packsPerPlayer: 2,
          duplicates: true,
        ).check(pool, 2),
        isNull,
      );
      expect(
        const PackRules(keepMax: 9).check(pool, 2),
        RulesIssue.keepAbovePack,
      );
      expect(
        const PackRules(keepMin: 3, keepMax: 2).check(pool, 2),
        RulesIssue.keepInvalid,
      );
    });
  });

  group('dealing', () {
    test('is deterministic and sized by the rules', () {
      final a = start(rules: const PackRules(packsPerPlayer: 2));
      final b = start(rules: const PackRules(packsPerPlayer: 2));
      expect(jsonEncode(a.toJson()), jsonEncode(b.toJson()));
      expect(a.players.length, 2);
      expect(a.players.first.packs.length, 4);
      expect(a.players.first.packs.every((p) => p.cards.length == 4), isTrue);
      expect(
        jsonEncode(start(seed: 8).toJson()) == jsonEncode(start().toJson()),
        isFalse,
      );
    });

    test('never repeats a card for one player without duplicates', () {
      final s = start(rules: const PackRules(packsPerPlayer: 2));
      for (final p in s.players) {
        for (final category in p.categories) {
          final names = [
            for (final pack in p.packs)
              if (pack.category == category)
                for (final c in pack.cards) c.card.name,
          ];
          expect(names.toSet().length, names.length);
        }
      }
    });

    test('rarity covers every tier over many rolls', () {
      final s = start(
        rules: const PackRules(cardsPerPack: 8, packsPerPlayer: 1),
        names: [for (var i = 0; i < 40; i++) 'P$i'],
      );
      final seen = {
        for (final p in s.players)
          for (final pack in p.packs)
            for (final c in pack.cards) c.rarity,
      };
      expect(seen, containsAll(CardRarity.values));
      expect(CardRarity.holo.foil && CardRarity.ultra.foil, isTrue);
      expect(CardRarity.rare.foil, isFalse);
    });
  });

  group('keeping', () {
    test('never exceeds the keep limit per category', () {
      var s = start(rules: const PackRules(keepMax: 2, keepMin: 1));
      s = s.open(0, 0);
      for (var c = 0; c < 4; c++) {
        s = s.toggle(0, 0, c);
      }
      expect(s.players[0].keptIn('Origin'), 2);
      s = s.toggle(0, 0, 0);
      expect(s.players[0].keptIn('Origin'), 1);
      s = s.toggle(0, 0, 3);
      expect(s.players[0].keptIn('Origin'), 2);
    });

    test('closed packs cannot be kept from', () {
      final s = start().toggle(0, 0, 0);
      expect(s.players[0].kept, isEmpty);
    });

    test('validation needs every category in range and all packs opened', () {
      var s = start();
      expect(s.players[0].ready(s.rules), isFalse);
      s = s.open(0, 0).open(0, 1).toggle(0, 0, 0);
      expect(s.players[0].missing(s.rules), 1);
      expect(s.validate(0).players[0].validated, isFalse);
      s = s.toggle(0, 1, 2);
      expect(s.players[0].ready(s.rules), isTrue);
      s = s.validate(0);
      expect(s.players[0].validated, isTrue);
      expect(s.toggle(0, 0, 0).players[0].keptIn('Origin'), 1);
      expect(s.complete, isFalse);
    });
  });

  group('rerolls', () {
    test('replace only the chosen pack and never go below zero', () {
      var s = start(rules: const PackRules(rerolls: 1)).open(0, 0).open(0, 1);
      s = s.toggle(0, 0, 0);
      final before = s.players[0];
      s = s.reroll(0, 0);
      final after = s.players[0];
      expect(after.packs[0].rerollsUsed, 1);
      expect(after.packs[0].opened, isFalse);
      expect(after.kept, isEmpty);
      expect(after.packs[1].toJson(), before.packs[1].toJson());
      final again = s.reroll(0, 0);
      expect(again.players[0].packs[0].rerollsUsed, 1);
    });

    test('are impossible when the game master allows none', () {
      final s = start(rules: const PackRules(rerolls: 0)).reroll(0, 0);
      expect(s.players[0].packs[0].rerollsUsed, 0);
    });
  });

  group('persistence', () {
    test('json round trip keeps deal, opening and choices', () {
      var s = start().open(0, 0).toggle(0, 0, 1);
      s = CardPackSession.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
      );
      expect(s.players[0].packs[0].opened, isTrue);
      expect(s.players[0].isKept(0, 1), isTrue);
      expect(
        jsonEncode(s.toJson()),
        jsonEncode(start().open(0, 0).toggle(0, 0, 1).toJson()),
      );
    });

    test('the cubit saves, restores and rides the backup', () async {
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      await getIt<LoadWorkspaceUseCase>()();
      final cubit = CardPackCubit(
        getIt<ReadCardPackSessionUseCase>(),
        getIt<SaveCardPackSessionUseCase>(),
      );
      expect(cubit.state, isNull);
      expect(
        cubit.begin(
          id: 's',
          template: 'Demo',
          rules: const PackRules(cardsPerPack: 20),
          pool: pool,
          names: const ['Ana'],
          seed: 1,
          now: 1,
        ),
        RulesIssue.poolTooSmall,
      );
      cubit.begin(
        id: 's',
        template: 'Demo',
        rules: const PackRules(),
        pool: pool,
        names: const ['Ana', 'Bo'],
        seed: 1,
        now: 1,
      );
      await cubit.open(0, 0);
      await cubit.toggle(0, 0, 0);
      final backup = getIt<ExportBackupUseCase>()();
      expect(jsonDecode(backup), contains('cardPacks'));
      await cubit.end();
      expect(
        jsonDecode(getIt<ExportBackupUseCase>()()),
        isNot(contains('cardPacks')),
      );
      await getIt<ImportBackupUseCase>()(backup);
      final restored = CardPackCubit(
        getIt<ReadCardPackSessionUseCase>(),
        getIt<SaveCardPackSessionUseCase>(),
      );
      expect(restored.state!.players[0].isKept(0, 0), isTrue);
      expect(restored.state!.players.length, 2);
      await db.close();
      await getIt.reset();
    });
  });
}
