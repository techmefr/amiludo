import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/phase_sequence_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/phases_tool.dart';

void main() {
  const seconds = [10, 20, 30];
  PhaseSequenceState sequence() =>
      PhaseSequenceState.of([for (final s in seconds) Duration(seconds: s)])
          .toggled();

  test('phases follow one another and loop into a new round', () {
    var state = sequence().tick(const Duration(seconds: 12));
    expect(state.index, 1);
    expect(state.remaining, const Duration(seconds: 18));
    state = state.tick(const Duration(seconds: 18 + 30 + 4));
    expect(state.index, 0);
    expect(state.round, 2);
    expect(state.remaining, const Duration(seconds: 6));
  });

  test('phases are edited only while stopped and stay in bounds', () {
    final state = PhaseSequenceState.of([
      for (final s in seconds) Duration(seconds: s),
    ]);
    expect(
      state.adjusted(PhaseSequenceState.step).current,
      const Duration(seconds: 40),
    );
    expect(state.adjusted(-const Duration(seconds: 30)).current, state.current);
    expect(state.added().durations.length, 4);
    expect(state.removed().durations.length, 2);
    expect(state.removed().removed().durations.length, 2);
    expect(state.toggled().added().durations.length, 3);
    expect(state.select(2).current, const Duration(seconds: 30));
  });

  testWidgets('start runs the first phase of the sequence', (tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PhasesTool(sound: false, haptics: false)),
      ),
    );
    expect(find.text('Phase 1'), findsOneWidget);
    expect(find.text('Round 1'), findsOneWidget);
    await tester.tap(find.text('Add a phase'));
    await tester.pump();
    expect(find.text('4 · 01:00'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
