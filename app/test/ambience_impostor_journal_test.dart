import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/presentation/ambience_tool.dart';
import 'package:amiludo/layers/functional/Journal/domain/entities/game_log.dart';
import 'package:amiludo/layers/functional/Journal/presentation/journal_tool.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/impostor_round.dart';
import 'package:amiludo/layers/functional/Random/presentation/impostor_tool.dart';
import 'package:amiludo/layers/technical/Sound/ambient_output.dart';
import 'package:amiludo/layers/technical/Sound/ambient_sounds.dart';

Widget _host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  _ambienceTests();
  _impostorTests();
  _journalTests();
}

void _ambienceTests() {
  test('every ambience renders a cached looping wav', () {
    for (final kind in AmbientKind.values) {
      final wav = ambientLoop(kind);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(wav.length, greaterThan(100000));
      expect(identical(wav, ambientLoop(kind)), isTrue);
    }
  });

  testWidgets('sliders start and silence the sounds', (tester) async {
    final output = RecordingAmbientOutput();
    await tester.pumpWidget(_host(AmbienceTool(output: output)));
    expect(output.playing, isEmpty);
    await tester.drag(find.byType(Slider).first, const Offset(150, 0));
    await tester.pump();
    expect(output.playing.keys, ['rain']);
    await tester.tap(find.text('Silence everything'));
    await tester.pump();
    expect(output.playing, isEmpty);
  });
}

void _impostorTests() {
  test('one impostor is dealt and every player sees a role in turn', () {
    var round = ImpostorRound.deal(' apple ', 5, Random(2));
    expect(round.word, 'apple');
    expect(round.impostor, inInclusiveRange(0, 4));
    var impostors = 0;
    while (!round.done) {
      if (round.holderIsImpostor) impostors++;
      round = round.advance();
    }
    expect(impostors, 1);
    expect(round.turn, 5);
    expect(round.advance().seen, 5);
  });

  testWidgets('roles are shown one by one then the impostor is revealed', (
    tester,
  ) async {
    await tester.pumpWidget(_host(ImpostorTool(random: Random(2))));
    await tester.tap(find.text('Deal the roles'));
    await tester.pump();
    expect(find.text('Player 1 of 5'), findsNothing);
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.tap(find.text('Deal the roles'));
    await tester.pumpAndSettle();
    expect(find.text('Player 1 of 5'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Show my role'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide and pass on'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Everyone knows their role.'), findsOneWidget);
    await tester.tap(find.text('Reveal the impostor'));
    await tester.pumpAndSettle();
    expect(find.textContaining('The impostor was player'), findsOneWidget);
    expect(find.text('apple'), findsOneWidget);
  });
}

void _journalTests() {
  test('the log keeps the newest entry first and ignores blanks', () {
    final start = DateTime.utc(2026, 11, 8, 10);
    var log = const GameLog().add('  first  ', start);
    log = log.add('   ', start).add('second', start);
    expect(log.entries.map((e) => e.text), ['second', 'first']);
    final copy = GameLog.fromJson(log.toJson());
    expect(copy.entries.first.text, 'second');
    expect(copy.entries.first.at, start);
    expect(log.remove(log.entries.first.id).entries.single.text, 'first');
  });

  testWidgets('a note is added and deleted', (tester) async {
    GameLog? saved;
    await tester.pumpWidget(
      _host(
        JournalTool(
          now: () => DateTime.utc(2026, 11, 8, 10),
          onChanged: (log) => saved = log,
        ),
      ),
    );
    expect(find.text('The log is empty.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'First blood');
    await tester.tap(find.text('Add to the log'));
    await tester.pump();
    expect(find.text('First blood'), findsOneWidget);
    expect(find.text('The log is empty.'), findsNothing);
    expect(saved!.entries.length, 1);
    await tester.tap(find.byTooltip('Delete entry'));
    await tester.pump();
    expect(find.text('The log is empty.'), findsOneWidget);
  });
}
