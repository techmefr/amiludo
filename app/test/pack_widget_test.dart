import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/router.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_tool.dart';

void main() {
  _fingerToolTests();
  _builderTests();
}

void _fingerToolTests() {
  testWidgets('finger tool is a dedicated page, expands and returns to tools', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    router.go('/tools');
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ouvrir ↗').first);
    await tester.tap(find.text('Ouvrir ↗').first);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(FingerTool), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    final area = find
        .ancestor(
          of: find.text('POSEZ VOS DOIGTS ICI'),
          matching: find.byType(Stack),
        )
        .first;
    expect(tester.getSize(area).height, greaterThan(350));
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(FingerTool), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await db.close();
    router.go('/');
  });
}

void _builderTests() {
  testWidgets('builder opened directly saves dice and returns to the library', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    router.go('/builder/new');
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du jeu ou du pack'),
      'My pack',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du jeu en anglais'),
      'My game',
    );
    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await tester.pump();
    await tester.ensureVisible(find.text('Lancer les dés'));
    await tester.tap(find.text('Lancer les dés'));
    await tester.pump();
    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await tester.pump();
    await tester.ensureVisible(find.text('Ajouter un dé'));
    await tester.tap(find.text('Ajouter un dé'));
    await tester.pump();
    while (find.text('Enregistrer le pack').evaluate().isEmpty) {
      await tester.ensureVisible(find.text('Continuer'));
      await tester.tap(find.text('Continuer'));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Enregistrer le pack'));
    await tester.tap(find.text('Enregistrer le pack'));
    await tester.pumpAndSettle();
    expect(find.text('My pack'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await db.close();
    router.go('/');
  });
}
