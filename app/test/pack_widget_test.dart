import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_companion/main.dart';
import 'package:table_companion/layers/technical/Storage/store_database.dart';
import 'package:table_companion/layers/functional/Workspace/workspace_controller.dart';
import 'package:table_companion/layers/functional/Random/presentation/finger_tool.dart';

void main() {
  testWidgets('finger tool is a dedicated page, expands and returns to tools', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    router.go('/tools');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const CompanionApp(),
      ),
    );
    await tester.pumpAndSettle();
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
  testWidgets('builder opened directly saves dice and returns to the library', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    router.go('/builder/new');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const CompanionApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nom du jeu ou du pack'),
      'My pack',
    );
    await tester.ensureVisible(find.text('Ajouter un dé'));
    await tester.tap(find.text('Ajouter un dé'));
    await tester.pump();
    await tester.ensureVisible(find.text('Enregistrer le pack'));
    await tester.tap(find.text('Enregistrer le pack'));
    await tester.pumpAndSettle();
    expect(find.text('MY PACK'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await db.close();
    router.go('/');
  });
}
