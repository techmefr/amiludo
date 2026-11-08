import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/chess_clock_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/chess_clock_tool.dart';

void main() {
  const minute = Duration(minutes: 1);
  const bonus = Duration(seconds: 2);

  test('the first tap starts the opponent clock and adds no increment', () {
    var state = ChessClockState.start(minute, bonus).press(0);
    expect(state.active, 1);
    expect(state.remaining[0], minute);
    state = state.tick(const Duration(seconds: 10));
    expect(state.remaining[1], const Duration(seconds: 50));
    state = state.press(1);
    expect(state.active, 0);
    expect(state.remaining[1], const Duration(seconds: 52));
  });

  test('only the player on the move can press, and time can run out', () {
    final state = ChessClockState.start(minute, bonus).press(0);
    expect(state.press(0), same(state));
    final out = state.tick(const Duration(minutes: 2));
    expect(out.flagged, 1);
    expect(out.remaining[1], Duration.zero);
    expect(out.running, isFalse);
    expect(out.press(1), same(out));
  });

  test('pausing freezes the clock', () {
    final paused = ChessClockState.start(minute, bonus).press(0).togglePause();
    expect(paused.tick(minute), same(paused));
    expect(formatClock(const Duration(seconds: 125)), '02:05');
    expect(formatClock(const Duration(milliseconds: 4300)), '0:04.3');
  });

  testWidgets('tapping a side starts the other clock', (tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ChessClockTool()),
      ),
    );
    expect(find.text('03:00'), findsNWidgets(2));
    await tester.tap(find.text('03:00').last);
    await tester.pump();
    await tester.tap(find.text('1 + 0'));
    await tester.pump();
    expect(find.text('01:00'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
  });
}
