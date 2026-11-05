import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_tile.dart';
import 'package:amiludo/main.dart';

const sizes = [Size(390, 844), Size(1280, 720), Size(1920, 1080)];

void main() {
  for (final size in sizes) {
    testWidgets('home has one primary action and fits at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      await tester.pumpWidget(const AmiludoApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(DeckTile), findsAtLeastNWidgets(4));
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }
}
