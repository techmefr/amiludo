import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_add_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  test(
    'the display mode survives json and a cleared session keeps history',
    () {
      const settings = DiceTraySettings(resultMode: 'best');
      expect(DiceTraySettings.fromJson(settings.toJson()).resultMode, 'best');
      expect(const DiceTraySettings().toJson().containsKey('result'), isFalse);
      final session = DiceTraySession(
        settings: settings,
        values: const [3, 4],
        history: const [
          TrayRoll([3, 4], 7),
        ],
      );
      expect(session.withMode('worst').values, [3, 4]);
      expect(session.withMode('worst').settings.resultMode, 'worst');
      final cleared = session.cleared();
      expect(cleared.thrown, isFalse);
      expect(cleared.history, isNotEmpty);
    },
  );

  testWidgets('the bar picks a display mode and erases the result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    DiceTraySettings? saved;
    await tester.pumpWidget(
      host(DiceTrayPage(seed: 5, solid: true, onChanged: (s) => saved = s)),
    );
    await tester.tap(find.text('Throw'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    await tester.tap(find.byTooltip('Result display'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Best').last);
    await tester.pumpAndSettle();
    expect(saved?.resultMode, 'best');
    await tester.tap(find.byTooltip('Clear result'));
    await tester.pump();
    expect(find.text('–'), findsOneWidget);
    expect(find.byTooltip('History'), findsOneWidget);
  });

  testWidgets('more dice sides can be added from the sheet', (tester) async {
    DiceTraySettings last = const DiceTraySettings(dice: []);
    await tester.pumpWidget(
      host(DiceAddList(settings: last, onChanged: (s) => last = s)),
    );
    await tester.tap(find.text('+ d1000'));
    await tester.pump();
    expect(last.dice.single.sides, 1000);
    expect(find.text('d1000'), findsOneWidget);
  });
}
