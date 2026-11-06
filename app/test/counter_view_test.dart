import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Companion/presentation/counter_view.dart';

Widget host(Widget child, {Size? size}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(child: SizedBox(width: 320, child: child)),
  ),
);

void main() {
  testWidgets('plus and minus change the value, undo restores it', (
    tester,
  ) async {
    final state = CounterState(pointsPreset);
    await tester.pumpWidget(host(CounterView(state: state)));
    await tester.tap(find.byTooltip('Increase'));
    await tester.tap(find.byTooltip('Increase'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(state.value, 1);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(state.value, 0);
  });

  testWidgets('life stops at zero and shows the outcome', (tester) async {
    final state = CounterState(lifePreset, value: 1);
    await tester.pumpWidget(host(CounterView(state: state)));
    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();
    await tester.tap(find.byTooltip('Decrease'));
    await tester.pump();
    expect(state.value, 0);
    expect(find.text('Eliminated'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('hearts and pips draw one symbol per point of maximum', (
    tester,
  ) async {
    const hearts = CounterSettings(
      maximum: 5,
      minimum: 0,
      start: 3,
      display: CounterDisplay.hearts,
    );
    await tester.pumpWidget(host(CounterView(state: CounterState(hearts))));
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));
    const pips = CounterSettings(
      maximum: 4,
      minimum: 0,
      start: 1,
      display: CounterDisplay.pips,
    );
    await tester.pumpWidget(host(CounterView(state: CounterState(pips))));
    expect(find.byIcon(Icons.circle), findsNWidgets(1));
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(3));
  });

  testWidgets('a long name and a large value stay inside the card', (
    tester,
  ) async {
    final state = CounterState(
      const CounterSettings(name: 'A very long counter name for a hero'),
      value: 123456789,
    );
    await tester.pumpWidget(host(CounterView(state: state)));
    expect(tester.takeException(), isNull);
  });
}
