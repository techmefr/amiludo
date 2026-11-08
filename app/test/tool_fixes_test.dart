import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_shelves.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_config_menu.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

void main() {
  test('the legacy dice tool is not listed any more', () {
    expect(brickEntries.any((e) => e.id == 'dice'), isFalse);
    expect([for (final s in toolShelves) ...s.tools], isNot(contains('dice')));
    expect([for (final s in toolShelves) ...s.tools], contains('dice-tray'));
  });

  for (final size in const [Size(390, 844), Size(844, 390), Size(1280, 720)]) {
    testWidgets('dice opens the 3D tray first at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      await tester.pumpWidget(const AmiludoApp());
      await tester.pumpAndSettle();
      router.go('/tools/dice');
      await tester.pumpAndSettle();
      expect(find.byType(DiceTrayPage), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.byType(ToolConfigMenu), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }

  testWidgets('the winning disc stays after the fingers lift', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    router.go('/tools/picker');
    await tester.pumpAndSettle();
    final a = await tester.startGesture(const Offset(120, 300));
    final b = await tester.startGesture(const Offset(260, 420));
    await tester.pump(const Duration(seconds: 2));
    await a.up();
    await b.up();
    await tester.pump();
    final states = tester
        .widgetList<FingerRing>(find.byType(FingerRing))
        .map((r) => r.state);
    expect(states.where((s) => s == FingerRingState.winner), hasLength(1));
    final chips = tester.getTopLeft(find.byType(FingerModeSelector));
    expect(chips.dy, greaterThanOrEqualTo(fullPageBackClearance));
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
