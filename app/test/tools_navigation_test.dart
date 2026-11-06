import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_page.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

void main() {
  for (final size in const [Size(390, 844), Size(1440, 1100)]) {
    testWidgets('tool title opens its tool at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      await tester.pumpWidget(const AmiludoApp());
      await tester.pumpAndSettle();
      router.go('/tools');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Qui commence ?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Qui commence ?'));
      await tester.pumpAndSettle();
      expect(find.byType(ToolPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }
}
