import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/hero.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/power.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/team.dart';
import 'package:amiludo/layers/functional/Companion/presentation/heroes_tool.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

TeamState sample() => TeamState(
  const TeamSettings(
    heroes: [
      HeroSettings(
        name: 'Ada',
        powers: [PowerSettings(name: 'Surge', threshold: 2)],
      ),
      HeroSettings(name: 'Bo'),
    ],
  ),
);

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('a power charges, enables Use, then is used at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final team = sample();
      await tester.pumpWidget(host(HeroesTool(team: team)));
      expect(find.text('Surge'), findsOneWidget);
      expect(find.text('Charging  0/2'), findsOneWidget);
      FilledButton use() => tester.widget(find.byType(FilledButton));
      expect(use().onPressed, isNull);
      await tester.tap(find.byTooltip('Add a charge'));
      await tester.tap(find.byTooltip('Add a charge'));
      await tester.pump();
      expect(find.text('Ready  2/2'), findsOneWidget);
      await tester.tap(find.text('Use'));
      await tester.pump();
      expect(find.text('Used  0/2'), findsOneWidget);
      await tester.tap(find.byTooltip('Recharge'));
      await tester.pump();
      expect(find.text('Charging  0/2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('choosing another hero switches the tile', (tester) async {
    final team = sample();
    await tester.pumpWidget(host(HeroesTool(team: team)));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Bo'));
    await tester.pump();
    expect(team.active?.name, 'Bo');
    expect(find.text('Surge'), findsNothing);
  });

  testWidgets('an empty team invites to add a hero', (tester) async {
    await tester.pumpWidget(host(const HeroesTool()));
    expect(find.text('No hero yet. Add one to start.'), findsOneWidget);
    await tester.tap(find.text('Add a hero'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cy');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Add a power'), findsOneWidget);
  });
}
