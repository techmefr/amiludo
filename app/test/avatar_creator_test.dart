import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/hero.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_color_row.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_creator_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hero_avatar.dart';

const _items = '''
{"version":1,"items":[
{"id":"eyes.a","slot":"eyes","peoples":[],"variants":{"average":{"layers":[{"order":75,"src":"avatar/pieces/eyes-sheet-1","tint":"eyes"}],"hideBodyParts":[]}}},
{"id":"weapon.b","slot":"weapon","peoples":[],"variants":{"average":{"layers":[{"order":100,"src":"avatar/pieces/sidearms-sheet-1"}],"hideBodyParts":[]}}}
]}
''';
const _palettes = '{"version":1,"palettes":{"eyes":["#112233","#445566"]}}';

Finder labelled(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);

AvatarCatalogue sample() => AvatarCatalogue.decode(_items, _palettes);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  test('a look survives the json round trip', () {
    final look = const AvatarLook().withPick('eyes', const AvatarPick('eyes.a', 5));
    final back = AvatarLook.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonEncode(look.toJson())) as Map),
    );
    expect(back.picks['eyes']!.itemId, 'eyes.a');
    expect(back.picks['eyes']!.color, 5);
    expect(back.withPick('eyes', null).isEmpty, isTrue);
  });

  test('an empty avatar is omitted from the hero backup', () {
    expect(const HeroSettings(name: 'Ada').toJson().containsKey('avatar'), isFalse);
    final json = HeroSettings(
      name: 'Ada',
      avatar: const AvatarLook({'eyes': AvatarPick('eyes.a')}),
    ).toJson();
    expect(HeroSettings.fromJson(json).avatar.picks['eyes']!.itemId, 'eyes.a');
    expect(HeroSettings.fromJson({'name': 'Bo'}).avatar.isEmpty, isTrue);
  });

  test('hero state keeps the avatar in its settings', () {
    final state = HeroState(const HeroSettings(name: 'Ada'));
    state.avatar = const AvatarLook({'weapon': AvatarPick('weapon.b')});
    expect(state.settings.avatar.picks.keys, ['weapon']);
  });

  test('shipped catalogue references existing tinted pieces', () {
    final catalogue = AvatarCatalogue.decode(
      File('assets/avatar/items.json').readAsStringSync(),
      File('assets/avatar/palettes.json').readAsStringSync(),
    );
    expect(catalogue.items.length, greaterThan(100));
    final ids = <String>{};
    for (final item in catalogue.items) {
      expect(ids.add(item.id), isTrue);
      for (final layer in catalogue.layersOf(item)) {
        expect(File('assets/${layer.src}.png').existsSync(), isTrue);
        if (layer.tint != null) {
          expect(catalogue.palettes.containsKey(layer.tint), isTrue);
        }
      }
    }
  });

  test('layers take the picked color or the first palette color', () {
    final catalogue = sample();
    final tinted = avatarLayers(
      const AvatarLook({'eyes': AvatarPick('eyes.a', 0xFF445566)}),
      catalogue,
    );
    expect(tinted.single.tint, const Color(0xFF445566));
    final fallback = avatarLayers(
      const AvatarLook({'eyes': AvatarPick('eyes.a')}),
      catalogue,
    );
    expect(fallback.single.tint, const Color(0xFF112233));
    final plain = avatarLayers(
      const AvatarLook({'weapon': AvatarPick('weapon.b')}),
      catalogue,
    );
    expect(plain.single.tint, isNull);
  });

  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('picking a piece and a color is returned on save at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      AvatarLook? saved;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                saved = await Navigator.of(context).push<AvatarLook>(
                  MaterialPageRoute(
                    builder: (_) => AvatarCreatorScreen(
                      initial: const AvatarLook(),
                      catalogue: sample(),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(labelled('Eyes 1'));
      await tester.pump();
      final swatches = find.descendant(
        of: find.byType(AvatarColorRow),
        matching: find.byType(InkWell),
      );
      await tester.tap(swatches.at(1));
      await tester.pump();
      await tester.tap(find.text('Weapons and tools'));
      await tester.pump();
      await tester.tap(labelled('Weapons and tools 1'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved!.picks['eyes']!.color, 0xFF445566);
      expect(saved!.picks['weapon']!.itemId, 'weapon.b');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('choosing none clears the slot', (tester) async {
    AvatarLook? saved;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              saved = await Navigator.of(context).push<AvatarLook>(
                MaterialPageRoute(
                  builder: (_) => AvatarCreatorScreen(
                    initial: const AvatarLook({'eyes': AvatarPick('eyes.a')}),
                    catalogue: sample(),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('None'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved!.isEmpty, isTrue);
  });
}
