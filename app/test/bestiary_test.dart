import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/entities/bestiary.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/entities/creature.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/use_cases/bestiary_use_cases.dart';
import 'package:amiludo/layers/functional/Bestiary/presentation/bestiary_tool.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

const wolf = Creature(
  id: 'w',
  name: 'Wolf',
  tags: ['beast', 'forest'],
  fields: [CreatureField('Attack', 'bite 1d6')],
  notes: 'Hunts in packs',
);
const mira = Creature(id: 'm', name: 'Mira', kind: CreatureKind.npc);
const gem = Creature(id: 'g', name: 'Ruby', kind: CreatureKind.treasure);

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
  const book = Bestiary(creatures: [wolf, mira, gem]);

  test('entries are filtered by text, kind and tag without accents', () {
    expect(book.filter().map((c) => c.id), ['m', 'g', 'w']);
    expect(book.filter(query: 'PACKS').map((c) => c.id), ['w']);
    expect(book.filter(query: 'bite').map((c) => c.id), ['w']);
    expect(book.filter(kind: CreatureKind.npc).map((c) => c.id), ['m']);
    expect(book.filter(tag: 'forest').map((c) => c.id), ['w']);
    expect(book.tags, ['beast', 'forest']);
  });

  test('entries are put, replaced and removed', () {
    final renamed = book.put(const Creature(id: 'w', name: 'Dire wolf'));
    expect(renamed.creatures.length, 3);
    expect(renamed.of('w')!.name, 'Dire wolf');
    expect(book.remove('w').of('w'), isNull);
  });

  test('an export imports back and merges into another bestiary', () {
    final result = const Bestiary(creatures: [mira]).import(book.export());
    expect(result, isNotNull);
    expect(result!.count, 3);
    expect(result.merged.creatures.length, 3);
    expect(result.merged.of('w')!.fields.single.value, 'bite 1d6');
  });

  test('a plain list imports and invalid text is refused', () {
    expect(
      const Bestiary()
          .import('[{"name": "Bat"}]')!
          .merged
          .creatures
          .single
          .name,
      'Bat',
    );
    expect(const Bestiary().import('not json'), isNull);
    expect(const Bestiary().import('{"a": 1}'), isNull);
    expect(const Bestiary().import('[{"name": " "}]'), isNull);
    expect(const Bestiary().import('[1]'), isNull);
  });
}

void _widgetTests() {
  testWidgets('the list is searched and filtered', (tester) async {
    await tester.pumpWidget(
      host(const BestiaryTool(initial: Bestiary(creatures: [wolf, mira, gem]))),
    );
    expect(find.text('Wolf'), findsOneWidget);
    expect(find.text('Mira'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'NPC'));
    await tester.pump();
    expect(find.text('Wolf'), findsNothing);
    expect(find.text('Mira'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.enterText(find.byType(TextField), 'ruby');
    await tester.pump();
    expect(find.text('Ruby'), findsOneWidget);
    expect(find.text('Wolf'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('Nothing matches.'), findsOneWidget);
  });

  testWidgets('an entry is created from the editor', (tester) async {
    Bestiary? saved;
    await tester.pumpWidget(host(BestiaryTool(onChanged: (b) => saved = b)));
    expect(
      find.text('Your bestiary is empty. Add a first entry.'),
      findsOneWidget,
    );
    await tester.tap(find.text('New entry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Goblin');
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved!.creatures.single.name, 'Goblin');
    expect(find.text('Goblin'), findsOneWidget);
  });
}

void _backupTests() {
  tearDown(getIt.reset);

  test('the bestiary is part of the backup and restores', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    await getIt<LoadWorkspaceUseCase>()();
    await getIt<SaveBestiaryUseCase>()(const Bestiary(creatures: [wolf]));
    final exported = getIt<ExportBackupUseCase>()();
    await getIt<SaveBestiaryUseCase>()(const Bestiary());
    await getIt<ImportBackupUseCase>()(exported);
    expect(getIt<ReadBestiaryUseCase>()().of('w')!.tags, ['beast', 'forest']);
    await db.close();
  });
}
