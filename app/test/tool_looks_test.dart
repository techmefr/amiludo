import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/remember_tool_use_case.dart';
import 'package:amiludo/layers/functional/Random/domain/use_cases/reorder_favorite_tools_use_case.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_card.dart';
import 'package:amiludo/layers/functional/Workspace/domain/entities/workspace.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

import 'fakes.dart';

void main() {
  _modelTests();
  for (final size in const [
    Size(390, 844),
    Size(844, 390),
    Size(1280, 720),
    Size(1920, 1080),
  ]) {
    _homeTest(size, reduced: false);
  }
  _homeTest(const Size(390, 844), reduced: true);
}

void _modelTests() {
  test('every tool has a look and a readable accent in light and dark', () {
    for (final entry in brickEntries) {
      expect(toolThemes.containsKey(entry.id), isTrue, reason: entry.id);
      final tool = toolThemes[entry.id]!;
      for (final base in const [Colors.white, Color(0xff1C1C1E)]) {
        final surface = Color.lerp(base, tool.accent, .16)!;
        expect(
          toolContrast(tool.ink(surface), surface),
          greaterThanOrEqualTo(4.5),
          reason: entry.id,
        );
      }
    }
  });

  test('every tool sits on exactly one shelf', () {
    final listed = [for (final s in toolShelves) ...s.tools];
    expect(listed.toSet().length, listed.length);
    expect(listed.toSet(), brickEntries.map((e) => e.id).toSet());
  });

  test('the hero resumes the last tool or features an unpinned one', () {
    expect(heroTool(lastTool: 'coin', favorites: const []), 'coin');
    expect(heroTool(lastTool: null, favorites: const []), 'dice-tray');
    expect(
      heroTool(lastTool: null, favorites: const ['dice-tray']),
      'hourglass',
    );
    final shelves = arrangeShelves(favorites: const ['dice'], hero: 'coin');
    final shown = [for (final s in shelves) ...s.tools];
    expect(shown, isNot(contains('dice')));
    expect(shown, isNot(contains('coin')));
  });

  test(
    'remembering and reordering tools persist through the workspace',
    () async {
      final gateway = MemoryWorkspace(
        const Workspace(favorites: ['a', 'b', 'c']),
      );
      await ReorderFavoriteToolsUseCase(gateway)('c', 'a');
      expect(gateway.current.favorites, ['c', 'a', 'b']);
      await ReorderFavoriteToolsUseCase(gateway)('c', '');
      expect(gateway.current.favorites, ['a', 'b', 'c']);
      await RememberToolUseCase(gateway)('map');
      expect(gateway.current.lastTool, 'map');
    },
  );

  test('the last tool is omitted from the export while unset', () {
    expect(const Workspace().toJson().containsKey('lastTool'), isFalse);
    final json = const Workspace(lastTool: 'map').toJson();
    expect(Workspace.fromJson(json).lastTool, 'map');
  });
}

void _homeTest(Size size, {required bool reduced}) {
  testWidgets('the tools home shows shelves at $size reduced=$reduced', (
    tester,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: reduced);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    router.go('/tools');
    await tester.pumpAndSettle();
    expect(find.byType(ToolCard), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
