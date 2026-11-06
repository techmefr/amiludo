import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/brick_ids.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/presentation/counter_view.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/presentation/brick_tile.dart';
import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/add_template_use_case.dart';
import 'package:amiludo/layers/functional/Templates/domain/use_cases/remove_template_use_case.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/read_workspace_use_case.dart';
import 'package:amiludo/layers/functional/Workspace/domain/use_cases/watch_workspace_use_case.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

import 'fakes.dart';

String _title(String id) => id;

void main() {
  _modelTests();
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    _screenTests(size);
  }
}

void _modelTests() {
  test('the catalog lists counters and every tool', () {
    final ids = brickEntries.map((e) => e.id).toSet();
    expect(ids, containsAll(['counter-life', 'counter-pot', 'dice-tray']));
    expect(ids, containsAll(['hourglass', 'heroes', 'picker', 'wheel']));
    expect(ids.length, brickEntries.length);
  });

  test('filtering combines category, favorites and search', () {
    List<String> ids(String category, String query) => filterBricks(
      brickEntries,
      category: category,
      favorites: {'coin'},
      query: query,
      title: _title,
    ).map((e) => e.id).toList();
    expect(ids('favorites', ''), ['coin']);
    expect(ids('counters', ''), hasLength(4));
    expect(ids('all', 'HOURG'), ['hourglass']);
    expect(ids('time', 'zzz'), isEmpty);
  });

  test('a counter entry becomes a counter brick with its preset', () {
    final brick = counterEntries.first.toBrick();
    expect(brick.type, 'counter');
    expect(brick.id, 'life');
    expect(brick.settings['maximum'], 99);
    final tool = brickEntries.firstWhere((e) => e.id == 'timer').toBrick();
    expect((tool.id, tool.type), ('timer', 'timer'));
  });

  test('a repeated brick gets a free identifier', () {
    const first = Brick(id: 'timer', type: 'timer');
    final next = [first].withFreeId(first);
    expect(next.id, 'timer-2');
    expect([first, next].withFreeId(first).id, 'timer-3');
  });

  test('the templates cubit appends a brick to the chosen template', () async {
    final gateway = MemoryWorkspace(
      const Workspace(
        templates: [
          GameTemplate(id: 'a', name: 'A'),
          GameTemplate(id: 'b', name: 'B'),
        ],
      ),
    );
    final cubit = TemplatesCubit(
      ReadWorkspaceUseCase(gateway),
      WatchWorkspaceUseCase(gateway),
      AddTemplateUseCase(gateway),
      RemoveTemplateUseCase(gateway),
    );
    addTearDown(cubit.close);
    const brick = Brick(id: 'timer', type: 'timer');
    await cubit.addBrick('b', brick);
    await cubit.addBrick('b', brick);
    await cubit.addBrick('missing', brick);
    final templates = {for (final t in gateway.current.templates) t.id: t};
    expect(templates['a']!.bricks, isEmpty);
    expect(templates['b']!.bricks.map((b) => b.id), ['timer', 'timer-2']);
  });
}

late StoreDatabase _db;

Future<void> _boot(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(_db);
  addTearDown(getIt.reset);
  await tester.pumpWidget(const AmiludoApp());
  await tester.pumpAndSettle();
  router.go('/tools');
  await tester.pumpAndSettle();
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await _db.close();
}

void _screenTests(Size size) {
  testWidgets('search narrows the library at $size', (tester) async {
    await _boot(tester, size);
    await tester.enterText(find.byType(TextField), 'Cagnotte');
    await tester.pumpAndSettle();
    expect(find.byType(BrickTile), findsOneWidget);
    expect(find.text('Qui commence ?'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('Aucune brique pour cette recherche.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _close(tester);
  });

  testWidgets('favorites and counters categories filter at $size', (
    tester,
  ) async {
    await _boot(tester, size);
    await tester.tap(find.text('Favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Qui commence ?'), findsOneWidget);
    expect(find.text('Cagnotte'), findsNothing);
    await tester.tap(find.text('Compteurs'));
    await tester.pumpAndSettle();
    expect(find.byType(BrickTile), findsNWidgets(4));
    expect(find.text('Qui commence ?'), findsNothing);
    await tester.ensureVisible(find.byTooltip('Favori').first);
    await tester.tap(find.byTooltip('Favori').first);
    await tester.pumpAndSettle();
    final favorites = getIt<ReadWorkspaceUseCase>()().favorites;
    expect(favorites, contains('counter-life'));
    expect(tester.takeException(), isNull);
    await _close(tester);
  });

  testWidgets('a counter brick opens alone and full screen at $size', (
    tester,
  ) async {
    await _boot(tester, size);
    await tester.enterText(find.byType(TextField), 'Cagnotte');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ouvrir ↗'));
    await tester.tap(find.text('Ouvrir ↗'));
    await tester.pumpAndSettle();
    expect(find.byType(CounterView), findsOneWidget);
    expect(tester.getSize(find.byType(FullPage)), size);
    expect(tester.takeException(), isNull);
    await _close(tester);
  });

  testWidgets('add to a companion appends the brick at $size', (tester) async {
    await _boot(tester, size);
    await tester.runAsync(
      () => getIt<AddTemplateUseCase>()(
        const GameTemplate(id: 'mine', name: 'Ma partie'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cagnotte');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ajouter à un compagnon'));
    await tester.tap(find.text('Ajouter à un compagnon'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Ma partie'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Brique ajoutée au compagnon.'), findsOneWidget);
    final saved = getIt<ReadWorkspaceUseCase>()().templates.single;
    expect(saved.bricks.single.id, 'pot');
    expect(tester.takeException(), isNull);
    await _close(tester);
  });
}
