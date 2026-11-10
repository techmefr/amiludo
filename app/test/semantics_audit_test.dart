import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

const _routes = [
  '/',
  '/tools',
  '/tools?category=chance',
  '/tools?category=gm',
  '/tools/dice-tray',
  '/tools/wheel',
  '/tools/coin',
  '/tools/picker',
  '/tools/scores',
  '/tools/combat',
  '/templates',
  '/library',
  '/friends',
  '/history',
  '/appearance',
];

void main() {
  for (final size in const [Size(375, 812), Size(800, 900)]) {
    testWidgets('targets are 44dp and icon buttons are labelled at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final handle = tester.ensureSemantics();
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      router.go('/');
      await tester.pumpWidget(const AmiludoApp());
      await tester.pumpAndSettle();
      final report = <String>[];
      for (final route in _routes) {
        router.go(route);
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        for (final (name, guideline) in [
          ('label', labeledTapTargetGuideline),
          ('target', iOSTapTargetGuideline),
        ]) {
          final result = await guideline.evaluate(tester);
          if (!result.passed) {
            report.add('$route $name ${result.reason}');
          }
        }
      }
      await tester.pumpWidget(const SizedBox());
      await db.close();
      handle.dispose();
      expect(report, isEmpty, reason: report.join('\n'));
    });
  }
}
