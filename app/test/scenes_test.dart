import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Scenes/domain/entities/scene.dart';
import 'package:amiludo/layers/functional/Scenes/domain/entities/storyline.dart';
import 'package:amiludo/layers/functional/Scenes/domain/use_cases/storyline_use_cases.dart';
import 'package:amiludo/layers/functional/Scenes/presentation/scenes_tool.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/export_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/import_backup_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/load_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';

const inn = Scene(
  id: 'a',
  title: 'The inn',
  nextIds: ['b'],
  creatureIds: ['w'],
);
const road = Scene(id: 'b', title: 'The road', handout: 'A torn map');
const cave = Scene(id: 'c', title: 'The cave', nextIds: ['b']);

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
  const story = Storyline(scenes: [inn, road, cave]);

  test('scenes move within bounds and followers resolve', () {
    expect(story.move('a', -1).scenes.first.id, 'a');
    expect([for (final s in story.move('a', 1).scenes) s.id], ['b', 'a', 'c']);
    expect(story.move('c', 1).scenes.last.id, 'c');
    expect(story.followers(inn).single.id, 'b');
  });

  test('removing a scene unlinks it everywhere', () {
    final next = story.remove('b');
    expect(next.scenes.length, 2);
    expect(next.of('a')!.nextIds, isEmpty);
    expect(next.of('c')!.nextIds, isEmpty);
  });

  test(
    'putting a scene drops links to unknown scenes and replaces in place',
    () {
      final next = story.put(
        const Scene(id: 'a', title: 'Inn', nextIds: ['b', 'ghost', 'a']),
      );
      expect(next.scenes.length, 3);
      expect(next.scenes.first.title, 'Inn');
      expect(next.scenes.first.nextIds, ['b']);
      expect(story.put(const Scene(id: 'd', title: 'New')).scenes.last.id, 'd');
    },
  );

  test('a storyline survives a JSON round trip', () {
    final back = Storyline.fromJson(story.toJson());
    expect(back.scenes.length, 3);
    expect(back.of('a')!.creatureIds, ['w']);
    expect(back.of('b')!.hasHandout, isTrue);
    expect(back.of('c')!.hasHandout, isFalse);
  });
}

void _widgetTests() {
  testWidgets('scenes are listed, reordered and shown as a handout', (
    tester,
  ) async {
    Storyline? saved;
    await tester.pumpWidget(
      host(
        ScenesTool(
          initial: const Storyline(scenes: [inn, road]),
          creatureNames: const {'w': 'Wolf'},
          onChanged: (s) => saved = s,
        ),
      ),
    );
    expect(find.text('The inn'), findsOneWidget);
    expect(find.text('Wolf'), findsOneWidget);
    await tester.tap(find.byTooltip('Move The inn down'));
    await tester.pump();
    expect([for (final s in saved!.scenes) s.id], ['b', 'a']);
    await tester.tap(find.text('Show to players'));
    await tester.pumpAndSettle();
    expect(find.text('A torn map'), findsOneWidget);
    await tester.tap(find.byTooltip('Hide the handout'));
    await tester.pumpAndSettle();
    expect(find.text('A torn map'), findsNothing);
  });

  testWidgets('a scene is created from the editor', (tester) async {
    Storyline? saved;
    await tester.pumpWidget(host(ScenesTool(onChanged: (s) => saved = s)));
    await tester.tap(find.text('New scene'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Scene title'),
      'Ambush',
    );
    await tester.ensureVisible(find.text('Save scene'));
    await tester.tap(find.text('Save scene'));
    await tester.pumpAndSettle();
    expect(saved!.scenes.single.title, 'Ambush');
  });
}

void _backupTests() {
  tearDown(getIt.reset);

  test('the storyline is part of the backup and restores', () async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    await getIt<LoadWorkspaceUseCase>()();
    await getIt<SaveStorylineUseCase>()(const Storyline(scenes: [inn, road]));
    final exported = getIt<ExportBackupUseCase>()();
    await getIt<SaveStorylineUseCase>()(const Storyline());
    await getIt<ImportBackupUseCase>()(exported);
    expect(getIt<ReadStorylineUseCase>()().of('b')!.handout, 'A torn map');
    await db.close();
  });
}
