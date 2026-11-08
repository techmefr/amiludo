import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/metronome_state.dart';
import 'package:amiludo/layers/functional/Companion/presentation/metronome_tool.dart';

void main() {
  test('the beat interval follows the tempo and stays in bounds', () {
    const state = MetronomeState(bpm: 120);
    expect(state.interval, const Duration(milliseconds: 500));
    expect(state.withBpm(10).bpm, MetronomeState.slowest);
    expect(state.withBpm(999).bpm, MetronomeState.fastest);
    expect(state.withBeats(1).beats, MetronomeState.fewest);
    expect(state.withBeats(20).beats, MetronomeState.most);
  });

  test('beats loop around the measure and the first one is accented', () {
    var state = const MetronomeState(beats: 3);
    expect(state.accented, isTrue);
    state = state.next().next();
    expect(state.beat, 2);
    state = state.next();
    expect(state.accented, isTrue);
    expect(state.next().restarted().beat, 0);
  });

  testWidgets('a preset sets the tempo and start flips to pause', (
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
        home: Scaffold(body: MetronomeTool(sound: false, haptics: false)),
      ),
    );
    await tester.tap(find.text('120 BPM'));
    await tester.pump();
    expect(find.text('120'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(find.text('Pause'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });
}
