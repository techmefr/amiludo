import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_page.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/layers/functional/Random/presentation/time_tools_shell.dart';
import 'package:amiludo/layers/functional/Random/presentation/tool_switch_menu.dart';
import 'package:amiludo/router.dart';

void main() {
  testWidgets('time tools swipe between deep links and return to the toolbox', (
    tester,
  ) async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    router.go('/tools');
    await tester.pumpAndSettle();
    router.push('/tools/timer');
    await tester.pumpAndSettle();
    final shell = find.byType(TimeToolsShell);
    expect(shell, findsOneWidget);
    await tester.flingFrom(const Offset(620, 300), const Offset(-360, 0), 1000);
    await tester.pumpAndSettle();
    expect(tester.widget<ToolPage>(find.byType(ToolPage)).id, 'hourglass');
    expect(router.state.uri.path, '/tools/hourglass');
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();
    expect(shell, findsNothing);
    expect(router.state.uri.path, '/tools');
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

  testWidgets('the category menu switches tools without adding a back step', (
    tester,
  ) async {
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    router.go('/tools');
    await tester.pumpAndSettle();
    router.push('/tools/coin');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ToolSwitchMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plateau de dés'));
    await tester.pumpAndSettle();
    expect(tester.widget<ToolPage>(find.byType(ToolPage)).id, 'dice-tray');
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();
    expect(find.byType(ToolPage), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

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
      await tester.ensureVisible(find.text('Joueurs & tours'));
      await tester.tap(find.text('Joueurs & tours'));
      await tester.pumpAndSettle();
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
