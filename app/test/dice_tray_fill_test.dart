import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/technical/Theme/immersive_page.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ImmersivePage(title: 'Dice', child: child),
);

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('the board fills the page and configure opens at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(const DiceTrayPage(seed: 5, fill: true, solid: true)),
      );
      await tester.pump();
      expect(find.text('Throw'), findsOneWidget);
      await tester.tap(find.text('Throw'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byTooltip('Configure'));
      await tester.pumpAndSettle();
      expect(find.text('Add or remove dice'), findsOneWidget);
      expect(find.text('Style'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('configure offers the add, create and market entries', (
    tester,
  ) async {
    var designs = 0, market = 0;
    await tester.pumpWidget(
      host(
        DiceTrayPage(
          seed: 5,
          fill: true,
          onDesigns: () => designs++,
          onMarket: () => market++,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Configure'));
    await tester.pumpAndSettle();
    expect(find.text('Add or remove dice'), findsOneWidget);
    await tester.tap(find.text('Create or edit my dice'));
    await tester.pumpAndSettle();
    expect(designs, 1);
    await tester.tap(find.byTooltip('Configure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get dice from the market'));
    await tester.pumpAndSettle();
    expect(market, 1);
  });
}
