import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_stage.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_switcher.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

class _Counter extends StatefulWidget {
  const _Counter(this.name);
  final String name;
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int value = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => value++),
      child: Text('${widget.name}:$value'),
    ),
  );
}

const _bricks = [Brick(id: 'a', type: 'dice'), Brick(id: 'b', type: 'roles')];

Widget _stage({VoidCallback? onGrid}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: SessionStage(
    sessionId: 's',
    title: 'Session',
    bricks: _bricks,
    builder: (context, brick) => _Counter(brick.id),
    initial: 0,
    onGrid: onGrid ?? () {},
  ),
);

Future<void> _pick(WidgetTester tester, int index) async {
  await tester.tap(find.byTooltip('Switch tool'));
  await tester.pumpAndSettle();
  final sheet = find.byType(ToolSwitcherSheet);
  expect(sheet, findsOneWidget);
  await tester.tap(
    find.descendant(of: sheet, matching: find.byType(InkWell)).at(index),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('stage is full screen with back and companion buttons', (
    tester,
  ) async {
    var grid = 0;
    await tester.pumpWidget(_stage(onGrid: () => grid++));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    expect(find.byType(CompanionButton), findsOneWidget);
    expect(find.text('a:0'), findsOneWidget);
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();
    expect(grid, 1);
  });

  testWidgets('switching tools keeps the state of the others', (tester) async {
    await tester.pumpWidget(_stage());
    await tester.pumpAndSettle();
    await tester.tap(find.text('a:0'));
    await tester.pump();
    expect(find.text('a:1'), findsOneWidget);
    await _pick(tester, 1);
    expect(find.text('b:0'), findsOneWidget);
    expect(find.text('a:1'), findsNothing);
    await tester.tap(find.text('b:0'));
    await tester.pump();
    await _pick(tester, 0);
    expect(find.text('a:1'), findsOneWidget);
    expect(lastSessionTool('s'), 'a');
  });

  testWidgets('alt+right moves to the next tool', (tester) async {
    await tester.pumpWidget(_stage());
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(find.text('b:0'), findsOneWidget);
  });

  testWidgets('a tool opened alone has no companion button', (tester) async {
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
    expect(find.byType(CompanionButton), findsNothing);
    expect(find.byType(BackButtonIcon), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
