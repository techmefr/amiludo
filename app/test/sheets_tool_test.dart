import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/score_presets.dart';
import 'package:amiludo/layers/functional/Companion/presentation/sheet_tool.dart';

const names = ['Ana', 'Ben'];

void main() {
  test('the upper bonus applies from the threshold only', () {
    final yams = presetById('yams');
    final upper = [3, 6, 9, 12, 15, 18];
    expect(sheetBonus(yams, upper), 35);
    expect(sheetBonus(yams, [3, 6, 9, 12, 15, 17]), 0);
    expect(sheetTotal(yams, [...upper, 20, 0, 25]), 63 + 35 + 45);
  });

  test('catan points follow the value of each piece', () {
    final catan = presetById('catan');
    expect(sheetTotal(catan, [2, 1, 0, 1, 1]), 2 + 2 + 0 + 2 + 1);
    expect(catan.hasBonus, isFalse);
    expect(presetById('skyjo').lowestWins, isTrue);
    expect(presetById('unknown').id, 'yams');
  });

  testWidgets('a sheet totals, ranks and switches game', (tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: SheetTool(names: names)),
        ),
      ),
    );
    expect(
      find.text('Enter at least one score to see the ranking.'),
      findsNothing,
    );
    await tester.enterText(find.byType(TextField).at(0), '4');
    await tester.pump();
    expect(find.text('Winner'), findsOneWidget);
    await tester.tap(find.text('Catan'));
    await tester.pump();
    expect(find.text('Cities (2 points)'), findsOneWidget);
    expect(find.text('Winner'), findsNothing);
    await tester.tap(find.text('Skyjo'));
    await tester.pump();
    expect(find.text('Round 5'), findsOneWidget);
    await tester.tap(find.text('Add a round'));
    await tester.pump();
    expect(find.text('Round 6'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '30');
    await tester.enterText(find.byType(TextField).at(1), '12');
    await tester.pump();
    expect(find.text('Winner'), findsOneWidget);
    expect(find.text('Ben'), findsNWidgets(3));
  });
}
