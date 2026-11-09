import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Scenes/domain/entities/scene.dart';
import 'package:amiludo/layers/functional/Scenes/domain/entities/storyline.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/scenes_tool.dart';
import 'package:amiludo/layers/functional/Tables/domain/entities/roll_table.dart';
import 'package:amiludo/layers/functional/Tables/domain/use_cases/roll_tables_use_cases.dart';
import 'package:amiludo/layers/functional/Tables/presentation/tables_tool.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Sound/ambient_output.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

const inns = RollTable(id: 't', name: 'Inns', entries: ['Boar', 'Fox']);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  _domainTests();
  _widgetTests();
  _ambienceTests();
  _backupTests();
}

void _domainTests() {
  test('a table rolls an entry and an empty one rolls nothing', () {
    expect(inns.roll((count) => 1), 'Fox');
    expect(inns.roll((count) => 0), 'Boar');
    expect(const RollTable(id: 'e', name: 'Empty').roll((c) => 0), isNull);
  });

  test('entries come from text lines without blanks', () {
    final table = RollTable.fromText('x', 'Loot', ' ring \n\n coin\n');
    expect(table.entries, ['ring', 'coin']);
    expect(table.text, 'ring\ncoin');
  });

  test('tables are put, replaced, removed and survive JSON', () {
    var tables = const RollTables().put(inns);
    tables = tables.put(const RollTable(id: 't', name: 'Taverns'));
    expect(tables.tables.single.name, 'Taverns');
    final back = RollTables.fromJson(const RollTables(tables: [inns]).toJson());
    expect(back.of('t')!.entries, ['Boar', 'Fox']);
    expect(tables.remove('t').isEmpty, isTrue);
  });
}

void _widgetTests() {
  testWidgets('starter tables are added and rolled', (tester) async {
    RollTables? saved;
    await tester.pumpWidget(
      host(
        TablesTool(
          onChanged: (t) => saved = t,
          random: RandomTools(random: Random(1)),
        ),
      ),
    );
    await tester.tap(find.text('Add starter tables'));
    await tester.pump();
    expect(saved!.tables.length, 5);
    expect(find.text('Add starter tables'), findsNothing);
    expect(saved!.tables.first.entries.length, 8);
    await tester.tap(find.text('Roll Names'));
    await tester.pumpAndSettle();
    expect(
      saved!.tables.first.entries.any(
        (e) => find.text(e).evaluate().isNotEmpty,
      ),
      isTrue,
    );
  });

  testWidgets('a table is created from the editor', (tester) async {
    RollTables? saved;
    await tester.pumpWidget(host(TablesTool(onChanged: (t) => saved = t)));
    await tester.tap(find.text('New table'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Table name'),
      'Rain',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Entries, one per line'),
      'Drizzle\nStorm',
    );
    await tester.ensureVisible(find.text('Save table'));
    await tester.tap(find.text('Save table'));
    await tester.pumpAndSettle();
    expect(saved!.tables.single.entries, ['Drizzle', 'Storm']);
  });
}

void _ambienceTests() {
  testWidgets('a scene plays and stops its sound ambience', (tester) async {
    final output = RecordingAmbientOutput();
    await tester.pumpWidget(
      host(
        ScenesTool(
          initial: const Storyline(
            scenes: [Scene(id: 'a', title: 'Storm night', ambience: 'storm')],
          ),
          ambient: output,
        ),
      ),
    );
    await tester.tap(find.text('Play ambience: Storm'));
    await tester.pump();
    expect(output.playing.keys, ['storm']);
    await tester.tap(find.text('Stop the ambience'));
    await tester.pump();
    expect(output.playing, isEmpty);
  });

  test('a scene keeps its ambience through JSON and edits', () {
    const scene = Scene(id: 'a', title: 'Camp', ambience: 'fire');
    expect(Scene.fromJson(scene.toJson()).ambience, 'fire');
    final story = const Storyline()
        .put(scene)
        .put(const Scene(id: 'b', title: 'Road'));
    expect(story.of('a')!.ambience, 'fire');
  });
}

void _backupTests() {
  tearDown(getIt.reset);

  test('the tables are part of the backup and restore', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    await getIt<LoadWorkspaceUseCase>()();
    await getIt<SaveRollTablesUseCase>()(const RollTables(tables: [inns]));
    final exported = getIt<ExportBackupUseCase>()();
    await getIt<SaveRollTablesUseCase>()(const RollTables());
    await getIt<ImportBackupUseCase>()(exported);
    expect(getIt<ReadRollTablesUseCase>()().of('t')!.name, 'Inns');
    await db.close();
  });
}
