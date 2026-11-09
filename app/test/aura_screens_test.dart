import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_background.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_preview.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

const _sizes = [Size(375, 812), Size(768, 1024), Size(1280, 720)];

Future<StoreDatabase> _boot(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  router.go('/');
  await tester.pumpWidget(const AmiludoApp());
  await tester.pumpAndSettle();
  return db;
}

Future<void> _close(WidgetTester tester, StoreDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await db.close();
}

void main() {
  for (final size in _sizes) {
    testWidgets('home, tools, a tool and a GM tool carry an aura at $size', (
      tester,
    ) async {
      final db = await _boot(tester, size);
      expect(find.byType(AuraBackground), findsOneWidget);
      for (final route in ['/tools', '/tools?category=gm', '/tools/dice']) {
        router.go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
        expect(find.byType(AuraBackground), findsAtLeastNWidgets(1));
      }
      router.go('/tools/combat');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AuraBackground), findsAtLeastNWidgets(1));
      await _close(tester, db);
    });

    testWidgets('appearance previews every universe at $size', (tester) async {
      final db = await _boot(tester, size);
      router.go('/appearance');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AuraPreview, skipOffstage: false), findsNWidgets(6));
      await _close(tester, db);
    });
  }
}
