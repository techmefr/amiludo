import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/countdown_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/countdown_tool.dart';

void main() {
  test('the countdown drains, stops at zero and restarts from the total', () {
    var state = CountdownState.of(const Duration(seconds: 60)).toggled();
    state = state.tick(const Duration(seconds: 15));
    expect(state.fraction, closeTo(.75, 1e-9));
    state = state.tick(const Duration(minutes: 5));
    expect(state.finished, isTrue);
    expect(state.running, isFalse);
    state = state.toggled();
    expect(state.running, isTrue);
    expect(state.remaining, const Duration(seconds: 60));
  });

  test('the duration only changes while stopped and stays in bounds', () {
    final state = CountdownState.of(const Duration(seconds: 60));
    expect(
      state.adjusted(CountdownState.step).total,
      const Duration(seconds: 90),
    );
    expect(state.adjusted(-const Duration(seconds: 45)).total, state.total);
    expect(state.toggled().adjusted(CountdownState.step).total, state.total);
    expect(state.adjusted(const Duration(hours: 4)).total, state.total);
  });

  testWidgets('a preset sets the duration and start flips to pause', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CountdownTool(sound: false, haptics: false)),
      ),
    );
    expect(find.text('05:00'), findsOneWidget);
    await tester.tap(find.text('10 min'));
    await tester.pump();
    expect(find.text('10:00'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
