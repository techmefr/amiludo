import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';
import 'package:amiludo/layers/functional/Library/presentation/bookshelf.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/dependencies.dart';

Future<StoreDatabase> openApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  await tester.pumpWidget(const AmiludoApp());
  router.go('/');
  await tester.pumpAndSettle();
  return db;
}

void main() {
  testWidgets('a game is shelved, opened and suggested for tonight', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tester.tap(find.text('Ludothèque'));
    await tester.pumpAndSettle();
    expect(find.text('Étagères vides'), findsOneWidget);
    await tester.tap(find.text('Ajouter un jeu'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Pandemic');
    await tester.tap(find.text('Coopératif'));
    await tester.pump();
    await tester.ensureVisible(find.text('Ranger sur l’étagère'));
    await tester.tap(find.text('Ranger sur l’étagère'));
    await tester.pumpAndSettle();
    expect(find.byType(GameSpine), findsOneWidget);
    await tester.tap(find.byType(GameSpine));
    await tester.pumpAndSettle();
    expect(find.text('Jouer'), findsOneWidget);
    expect(find.text('Partager en QR'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On joue à quoi ce soir ?'));
    await tester.pumpAndSettle();
    expect(find.text('Pandemic'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

  testWidgets('a friend profile keeps tastes', (tester) async {
    final db = await openApp(tester);
    await tester.tap(find.text('Amis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter un ami'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Léa');
    await tester.tap(find.text('Bluff'));
    await tester.tap(find.text('Bluff'));
    await tester.pump();
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Léa'), findsOneWidget);
    expect(find.text('N’aime pas : Bluff'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
