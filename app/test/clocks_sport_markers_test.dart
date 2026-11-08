import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/progress_clock.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/sport_score.dart';
import 'package:amiludo/layers/functional/Companion/presentation/clocks_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/markers_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/sport_tool.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

const names = ['Ana', 'Ben'];

void main() {
  test('a clock fills up to its segments and can be removed', () {
    var clocks = addClock(const [], 'Doom', 4);
    clocks = addClock(clocks, '  ', 4);
    expect(clocks.length, 1);
    clocks = stepClock(clocks, 0, 9);
    expect(clocks.first.filled, 4);
    expect(clocks.first.full, isTrue);
    expect(stepClock(clocks, 0, -9).first.filled, 0);
    expect(removeClock(clocks, 0), isEmpty);
  });

  test('table sports follow their own rules', () {
    final molkky = sportMode('molkky');
    expect(molkky.apply(40, 12), 25);
    expect(molkky.apply(40, 10), 50);
    expect(molkky.won(50), isTrue);
    final darts = sportMode('darts');
    expect(darts.apply(501, 60), 441);
    expect(darts.apply(20, 25), 20);
    expect(darts.won(0), isTrue);
    expect(sportMode('petanque').won(13), isTrue);
    expect(sportMode('unknown').id, 'molkky');
  });

  testWidgets('clocks are added and ticked', (tester) async {
    await tester.pumpWidget(host(const ClocksTool()));
    await tester.tap(find.widgetWithText(FilledButton, 'Add a clock'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Doom');
    await tester.tap(find.widgetWithText(FilledButton, 'Add a clock').last);
    await tester.pumpAndSettle();
    expect(find.text('Doom'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase Doom'));
    await tester.pump();
    expect(find.byTooltip('Remove Doom'), findsOneWidget);
  });

  testWidgets('sport scores add points and switch mode', (tester) async {
    await tester.pumpWidget(host(const SportTool(names: names)));
    await tester.enterText(find.byType(TextField).first, '12');
    await tester.tap(find.byTooltip('Add points for Ana'));
    await tester.pump();
    expect(find.text('12'), findsOneWidget);
    await tester.tap(find.text('Darts 501'));
    await tester.pump();
    expect(find.text('501'), findsNWidgets(2));
  });

  testWidgets('a marker goes to one player and back', (tester) async {
    await tester.pumpWidget(host(const MarkersTool(names: names)));
    await tester.tap(find.text('Ana').first);
    await tester.pump();
    expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    await tester.tap(find.text('Ana').first);
    await tester.pump();
    expect(find.byIcon(Icons.workspace_premium), findsNothing);
  });
}
