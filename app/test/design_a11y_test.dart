import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

const routes = [
  '/',
  '/tools',
  '/templates',
  '/library',
  '/friends',
  '/history',
];

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('pages hold at 200 percent text at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      await tester.pumpWidget(const AmiludoApp());
      await tester.pumpAndSettle();
      for (final route in routes) {
        router.go(route);
        await tester.pumpAndSettle();
        final ex = tester.takeException();
        if (ex != null) {
          debugPrint(route);
        }
        expect(ex, isNull, reason: route);
      }
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }
}
