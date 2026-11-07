import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Notebook/presentation/dice_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('the dice sheet rolls an expression at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      String? inserted;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: deckTheme(const Appearance(), Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => inserted = await showDiceSheet(
                context,
                random: RandomTools(random: Random(3)),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '2d6+1');
      await tester.tap(find.text('Roll'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2d6+1 →'), findsOneWidget);
      await tester.tap(find.text('Add to journal'));
      await tester.pumpAndSettle();
      expect(inserted, startsWith('2d6+1 → '));
      expect(inserted, matches(RegExp(r'= \d+$')));
    });
  }

  test('a roll is described with its dice and modifier', () {
    expect(
      describeRoll('2d6-1', const DiceExpression([3, 4], -1)),
      '2d6-1 → 3 + 4 -1 = 6',
    );
    expect(
      describeRoll('1d20', const DiceExpression([12], 0)),
      '1d20 → 12 = 12',
    );
  });
}
