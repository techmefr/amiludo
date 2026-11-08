import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/immersive_page.dart';
import 'package:amiludo/layers/functional/Workspace/presentation/app_shell.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

Widget _host() => MaterialApp(
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ImmersivePage(
              title: 'Page',
              actions: [Icon(Icons.star)],
              child: Text('content'),
            ),
          ),
        ),
        child: const Text('open'),
      ),
    ),
  ),
);

void main() {
  testWidgets('immersive page has no app bar and a back button', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(
      tester.getSize(find.byType(BackButtonIcon).first).shortestSide > 0,
      isTrue,
    );
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('escape and alt+left go back from an immersive page', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('escape leaves a tool opened from the catalog', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    router.go('/tools');
    await tester.pumpAndSettle();
    router.push('/tools/roles');
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
