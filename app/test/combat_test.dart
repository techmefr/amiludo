import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Combat/domain/entities/combatant.dart';
import 'package:amiludo/layers/functional/Combat/domain/entities/encounter.dart';
import 'package:amiludo/layers/functional/Combat/domain/use_cases/encounter_use_cases.dart';
import 'package:amiludo/layers/functional/Combat/presentation/combat_tool.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

Combatant fighter(
  String id,
  String name,
  int? initiative, {
  int hp = 0,
  bool player = false,
}) => Combatant(
  id: id,
  name: name,
  initiative: initiative,
  hp: hp,
  maxHp: hp,
  player: player,
);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  _domainTests();
  _widgetTests();
  _backupTests();
}

void _domainTests() {
  test('the order sorts by initiative and keeps insertion order on ties', () {
    final encounter = Encounter(
      combatants: [
        fighter('a', 'Ana', 12),
        fighter('b', 'Ben', 18),
        fighter('c', 'Cid', 12),
        fighter('d', 'Dot', null),
      ],
    );
    expect([for (final c in encounter.ordered) c.id], ['b', 'a', 'c', 'd']);
    expect(encounter.missingInitiative, isTrue);
  });

  test('turns advance, rounds wrap and downed monsters are skipped', () {
    var encounter = Encounter(
      combatants: [
        fighter('a', 'Ana', 15, player: true),
        fighter('b', 'Orc', 10, hp: 5),
        fighter('c', 'Ben', 5, player: true),
      ],
    ).start();
    expect(encounter.turnId, 'a');
    encounter = encounter.update('b', (c) => c.hit(-9));
    expect(encounter.current!.id, 'a');
    encounter = encounter.next();
    expect(encounter.turnId, 'c');
    expect(encounter.round, 1);
    encounter = encounter.next();
    expect(encounter.turnId, 'a');
    expect(encounter.round, 2);
    expect(encounter.reset().started, isFalse);
  });

  test('hit points are clamped and conditions toggle', () {
    final orc = fighter('b', 'Orc', 10, hp: 5);
    expect(orc.hit(-99).hp, 0);
    expect(orc.hit(-99).down, isTrue);
    expect(orc.hit(99).hp, 5);
    expect(fighter('p', 'Pia', 3, hp: 5, player: true).hit(-9).down, isFalse);
    final stunned = orc.toggled('stunned');
    expect(stunned.conditions, ['stunned']);
    expect(stunned.toggled('stunned').conditions, isEmpty);
  });

  test('identical monsters are numbered and share their stats', () {
    final group = const Encounter().addGroup(
      Combatant(id: '100', name: 'Goblin', hp: 7, maxHp: 7, bonus: 2),
      3,
    );
    expect(
      [for (final c in group.combatants) c.name],
      ['Goblin 1', 'Goblin 2', 'Goblin 3'],
    );
    expect(group.combatants.map((c) => c.id).toSet().length, 3);
    expect(group.combatants.every((c) => c.maxHp == 7 && c.bonus == 2), isTrue);
    expect(const Encounter().addGroup(fighter('1', 'Solo', 1), 1).combatants, [
      isA<Combatant>(),
    ]);
  });

  test('initiative rolls add the bonus and only fill the blanks', () {
    final encounter = Encounter(
      combatants: [
        fighter('a', 'Ana', 3),
        Combatant(id: 'b', name: 'Ben', bonus: 2),
      ],
    );
    final filled = encounter.rollMissing((sides) => 10);
    expect(filled.combatants[0].initiative, 3);
    expect(filled.combatants[1].initiative, 12);
    expect(encounter.rollAll((sides) => 10).combatants[0].initiative, 10);
  });

  test('removing the current combatant passes the turn on', () {
    var encounter = Encounter(
      combatants: [fighter('a', 'Ana', 9), fighter('b', 'Ben', 4)],
    ).start();
    encounter = encounter.remove('a');
    expect(encounter.turnId, 'b');
    expect(encounter.remove('b').started, isFalse);
  });

  test('an encounter survives a JSON round trip', () {
    final encounter = Encounter(
      combatants: [fighter('a', 'Ana', 9, hp: 4).toggled('prone')],
      round: 3,
      turnId: 'a',
    );
    final back = Encounter.fromJson(
      jsonDecode(jsonEncode(encounter.toJson())) as Map<String, dynamic>,
    );
    expect(back.round, 3);
    expect(back.turnId, 'a');
    expect(back.combatants.single.conditions, ['prone']);
    expect(back.combatants.single.maxHp, 4);
  });
}

void _widgetTests() {
  testWidgets('a combat runs turn by turn through the rounds', (tester) async {
    await tester.pumpWidget(
      host(
        CombatTool(
          initial: Encounter(
            combatants: [
              fighter('a', 'Ana', 15),
              fighter('b', 'Orc', 8, hp: 6),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Start combat'));
    await tester.pump();
    expect(find.text('Round 1'), findsOneWidget);
    expect(find.text('Ana is playing'), findsOneWidget);
    await tester.tap(find.text('Next turn'));
    await tester.pump();
    expect(find.text('Orc is playing'), findsOneWidget);
    await tester.tap(find.text('Next turn'));
    await tester.pump();
    expect(find.text('Round 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove 1 hit point from Orc'));
    await tester.pump();
    expect(find.text('5 / 6'), findsOneWidget);
  });

  testWidgets('the 3D die sets the initiative with the bonus', (tester) async {
    Encounter? saved;
    await tester.pumpWidget(
      host(
        CombatTool(
          initial: Encounter(
            combatants: [
              Combatant(id: 'a', name: 'Ana', initiative: 1, bonus: 2),
            ],
          ),
          onChanged: (e) => saved = e,
          roller: (context, name) async => 14,
        ),
      ),
    );
    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Roll the 3D die'));
    await tester.pumpAndSettle();
    expect(saved!.combatants.single.initiative, 16);
  });

  testWidgets('without a roller the sheet offers no 3D die', (tester) async {
    await tester.pumpWidget(
      host(
        CombatTool(initial: Encounter(combatants: [fighter('a', 'Ana', 1)])),
      ),
    );
    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    expect(find.text('Roll the 3D die'), findsNothing);
  });

  testWidgets('a group of monsters is added from the sheet', (tester) async {
    Encounter? saved;
    await tester.pumpWidget(
      host(CombatTool(onChanged: (e) => saved = e, npcNames: const ['Mira'])),
    );
    expect(
      find.text('No combatants yet. Add the heroes and the monsters.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Mira'), findsOneWidget);
    await tester.tap(find.text('Mira'));
    await tester.pump();
    await tester.tap(find.byTooltip('More monsters'));
    await tester.pump();
    await tester.tap(find.byTooltip('More monsters'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(
      [for (final c in saved!.combatants) c.name],
      ['Mira 1', 'Mira 2', 'Mira 3'],
    );
    expect(find.text('Mira 2'), findsOneWidget);
  });
}

void _backupTests() {
  tearDown(getIt.reset);

  test('the encounter is part of the backup and restores', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    await getIt<LoadWorkspaceUseCase>()();
    await getIt<SaveEncounterUseCase>()(
      Encounter(combatants: [fighter('a', 'Ana', 9, hp: 4)], round: 2),
    );
    final exported = getIt<ExportBackupUseCase>()();
    await getIt<SaveEncounterUseCase>()(const Encounter());
    await getIt<ImportBackupUseCase>()(exported);
    final restored = getIt<ReadEncounterUseCase>()();
    expect(restored.round, 2);
    expect(restored.combatants.single.name, 'Ana');
    await db.close();
  });
}
