import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_catalog_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  test('favorites toggle, survive json and keep the other settings', () {
    const base = DiceTraySettings(resultMode: 'best');
    final starred = base.toggleFavorite('d20').toggleFavorite('d6');
    expect(starred.favorites, ['d20', 'd6']);
    expect(starred.toggleFavorite('d20').favorites, ['d6']);
    final restored = DiceTraySettings.fromJson(starred.toJson());
    expect(restored.favorites, ['d20', 'd6']);
    expect(restored.resultMode, 'best');
    expect(const DiceTraySettings().toJson().containsKey('favorites'), isFalse);
    expect(const DiceSpec(sides: 20).key, 'd20');
  });

  testWidgets('the catalog lists every size and filters favorites', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final starred = <String>[];
    DiceSpec? added;
    await tester.pumpWidget(
      host(
        DiceCatalogGrid(
          favorites: const [],
          onAdd: (s) => added = s,
          onFavorite: starred.add,
        ),
      ),
    );
    for (final sides in catalogSides) {
      expect(find.text('d$sides'), findsOneWidget);
    }
    await tester.tap(find.text('d1000'));
    expect(added?.sides, 1000);
    await tester.tap(find.byTooltip('Add to favorites').at(2));
    await tester.pump();
    expect(starred, ['d4']);
    await tester.tap(find.text('Favorites'));
    await tester.pump();
    expect(find.text('d4'), findsOneWidget);
    expect(find.text('d20'), findsNothing);
  });

  testWidgets('a long press on a die offers to remove it', (tester) async {
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
    await tester.longPress(find.byType(Die3dView).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove this die'));
    await tester.pumpAndSettle();
    expect(saved?.dice.length, 1);
  });
}
