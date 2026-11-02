import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_companion/main.dart';
import 'package:table_companion/layers/technical/Storage/store_database.dart';
import 'package:table_companion/layers/functional/Workspace/workspace_controller.dart';

void main() {
  testWidgets('create a real game, update a score and undo', (tester) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const CompanionApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('On joue à quoi, aujourd’hui ?'), findsOneWidget);
    await tester.tap(find.text('Nouvelle partie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('À vous de jouer'));
    await tester.pumpAndSettle();
    expect(find.text('Camille'), findsWidgets);
    await tester.tap(find.text('+5').first);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    await tester.tap(find.text('Annuler').first);
    await tester.pump();
    expect(find.text('0'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
