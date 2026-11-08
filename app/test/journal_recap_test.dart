import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Journal/domain/entities/game_log.dart';
import 'package:amiludo/layers/functional/Journal/presentation/journal_tool.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

GameLog sampleLog() => const GameLog()
    .add('Met the innkeeper', DateTime.utc(2026, 11, 1, 18))
    .add('Fought the wolves', DateTime.utc(2026, 11, 1, 20))
    .add('Found the key', DateTime.utc(2026, 11, 8, 19));

void main() {
  test('entries are grouped into sessions, newest first', () {
    final sessions = sampleLog().sessions();
    expect(sessions.length, 2);
    expect(sessions.first.entries.single.text, 'Found the key');
    expect(sessions.last.entries.map((e) => e.text), [
      'Met the innkeeper',
      'Fought the wolves',
    ]);
    expect(sessions.last.start, DateTime.utc(2026, 11, 1, 18));
    expect(sessions.last.end, DateTime.utc(2026, 11, 1, 20));
  });

  test('a short gap setting splits one evening into several sessions', () {
    final sessions = sampleLog().sessions(gap: const Duration(minutes: 30));
    expect(sessions.length, 3);
  });

  test('an empty log has no session', () {
    expect(const GameLog().sessions(), isEmpty);
  });

  testWidgets('the recap lists the entries of the latest session', (
    tester,
  ) async {
    await tester.pumpWidget(host(JournalTool(initial: sampleLog())));
    await tester.tap(find.text('Session recap'));
    await tester.pumpAndSettle();
    expect(find.text('Recap of the session'), findsOneWidget);
    expect(find.textContaining('Found the key'), findsWidgets);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Nov 1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fought the wolves'), findsWidgets);
  });

  testWidgets('the recap button is disabled for an empty log', (tester) async {
    await tester.pumpWidget(host(const JournalTool()));
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Session recap'),
    );
    expect(button.onPressed, isNull);
  });
}
