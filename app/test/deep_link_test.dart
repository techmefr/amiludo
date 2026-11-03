import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/dependencies.dart';

void main() {
  testWidgets('a full page opened by link leaves the loading state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    router.go('/setup');
    addTearDown(() => router.go('/'));
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    expect(find.text('Ouverture de votre table…'), findsNothing);
    expect(find.text('Préparer la table'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
