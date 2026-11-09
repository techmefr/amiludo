import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_timer_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/turn_timer_tool.dart';

void main() {
  test('passing resets the ring and loops around the table', () {
    var state = TurnTimerState.of(3, const Duration(seconds: 30)).pass();
    expect(state.current, 1);
    expect(state.running, isTrue);
    state = state.tick(const Duration(seconds: 10));
    expect(state.fraction, closeTo(2 / 3, 1e-9));
    state = state.pass().pass();
    expect(state.current, 0);
    expect(state.remaining, const Duration(seconds: 30));
    expect(state.turns, 3);
  });

  test('time running out stops the ring until the turn is passed', () {
    final state = TurnTimerState.of(
      2,
      const Duration(seconds: 15),
    ).pass().tick(const Duration(minutes: 1));
    expect(state.expired, isTrue);
    expect(state.running, isFalse);
    final resumed = state.toggled();
    expect(resumed.current, 0);
    expect(resumed.running, isTrue);
    expect(resumed.reset().pristine, isTrue);
  });

  testWidgets('next player moves the turn on', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: TurnTimerTool(sound: false, haptics: false)),
      ),
    );
    expect(find.text('Player 1'), findsOneWidget);
    await tester.tap(find.text('Next player'));
    await tester.pump();
    expect(find.text('Player 2'), findsOneWidget);
    await tester.tap(find.text('6'));
    await tester.pump();
    expect(find.text('Player 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
