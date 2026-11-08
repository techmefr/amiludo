import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_add_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_look_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_3d_view.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Dice3D/die_pips.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  test('skins and tables are data with unique ids and a default', () {
    expect(DieSkin.all.length, 8);
    expect({for (final s in DieSkin.all) s.id}.length, 8);
    expect(TableTheme.all.length, 6);
    expect({for (final t in TableTheme.all) t.id}.length, 6);
    expect(DieSkin.byId('nope'), DieSkin.classic);
    expect(TableTheme.byId('nope'), TableTheme.felt);
  });

  test('skin and table are omitted by default and round trip', () {
    final json = const Appearance().toJson();
    expect(json.containsKey('dieSkin'), isFalse);
    expect(json.containsKey('table'), isFalse);
    final chosen = const Appearance().copyWith(dieSkin: 'gold', table: 'blue');
    final back = Appearance.fromJson(chosen.toJson());
    expect(back.dieSkin, 'gold');
    expect(back.table, 'blue');
    final odd = Appearance.fromJson({...json, 'dieSkin': 'x', 'table': 7});
    expect(odd.dieSkin, 'matte');
    expect(odd.table, 'felt');
  });

  testWidgets('every skin renders every standard die', (tester) async {
    for (final skin in DieSkin.all) {
      for (final sides in [4, 6, 8, 10, 12, 20, 100]) {
        await tester.pumpWidget(
          host(
            Die3dView(
              spec: DiceSpec(sides: sides),
              value: 3,
              skin: skin,
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '${skin.id} d$sides');
      }
    }
  });

  testWidgets('d6 shows pips and custom faces keep their own content', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const Die3dView(spec: DiceSpec(sides: 6), value: 4)),
    );
    expect(find.byType(DiePips), findsWidgets);
    await tester.pumpWidget(
      host(
        Die3dView(spec: DiceSpec.custom(['x', 'y', 'z'], 0xFF336699), value: 1),
      ),
    );
    expect(find.byType(DiePips), findsNothing);
    expect(find.text('x'), findsWidgets);
  });

  testWidgets('the add sheet steps counts up and down live', (tester) async {
    DiceTraySettings last = const DiceTraySettings(dice: []);
    await tester.pumpWidget(
      host(DiceAddList(settings: last, onChanged: (s) => last = s)),
    );
    expect(find.text('d100'), findsOneWidget);
    expect(find.text('0 dice'), findsOneWidget);
    final adds = find.byTooltip('Add a die');
    await tester.tap(adds.last);
    await tester.pump();
    expect(last.dice.single.sides, 100);
    expect(find.text('1 dice'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove this die').last);
    await tester.pump();
    expect(last.dice, isEmpty);
  });

  testWidgets('the look picker reports skin and table choices', (tester) async {
    String? skin, table;
    await tester.pumpWidget(
      host(
        DiceLookPicker(
          skin: 'classic',
          table: 'felt',
          onSkin: (v) => skin = v,
          onTable: (v) => table = v,
        ),
      ),
    );
    await tester.tap(find.text('Gold'));
    await tester.tap(find.text('Blue'));
    expect(skin, 'gold');
    expect(table, 'blue');
  });

  for (final size in [const Size(390, 844), const Size(1280, 720)]) {
    testWidgets('3D tray fits ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      String? picked;
      await tester.pumpWidget(
        host(
          DiceTrayPage(
            seed: 3,
            solid: true,
            table: 'wood',
            skin: 'gold',
            onSkinChanged: (v) => picked = v,
          ),
        ),
      );
      await tester.tap(find.text('Throw'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(find.byType(Die3dView), findsNWidgets(2));
      expect(find.byTooltip('Style'), findsOneWidget);
      await tester.tap(find.text('Add a die'));
      await tester.pumpAndSettle();
      expect(find.text('d20'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(picked, isNull);
    });
  }
}
