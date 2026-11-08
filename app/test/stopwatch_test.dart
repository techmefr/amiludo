import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/stopwatch_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/stopwatch_tool.dart';

void main() {
  test('laps are cut from the running total', () {
    var state = const StopwatchState()
        .toggled()
        .withElapsed(const Duration(seconds: 5))
        .lapped()
        .withElapsed(const Duration(seconds: 12))
        .lapped();
    expect(state.laps.length, 2);
    expect(state.lapLength(1), const Duration(seconds: 7));
    expect(state.fastest, const Duration(seconds: 5));
    expect(state.slowest, const Duration(seconds: 7));
    expect(state.reset().pristine, isTrue);
    state = state.toggled().lapped();
    expect(state.laps.length, 2);
  });

  test('time shows hundredths and hours only when needed', () {
    expect(formatStopwatch(const Duration(milliseconds: 83450)), '01:23.45');
    expect(formatStopwatch(const Duration(hours: 1, seconds: 2)), '1:00:02.00');
  });

  testWidgets('start, lap and reset drive the buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: StopwatchTool()),
      ),
    );
    expect(find.text('00:00.00'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(find.text('Lap'));
    await tester.pump();
    expect(find.text('Lap 1'), findsOneWidget);
    await tester.tap(find.text('Pause'));
    await tester.pump();
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('Lap 1'), findsNothing);
  });
}
