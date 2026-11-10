import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue_loader.dart';
import 'package:amiludo/layers/functional/Companion/data/avatar_randomizer.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_color_row.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_creator_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hero_avatar.dart';
import 'package:amiludo/layers/technical/Avatar/avatar_fit.dart';

AvatarCatalogue shipped({bool rig = true}) => AvatarCatalogue.decode(
  File('assets/avatar/items.json').readAsStringSync(),
  File('assets/avatar/palettes.json').readAsStringSync(),
  rig ? File('assets/avatar/rig.json').readAsStringSync() : null,
);

AvatarLook standard(AvatarCatalogue c, [List<String> pieces = const []]) =>
    c.lookFor(tints: const {}, pieces: pieces, hairless: false);

Future<AvatarLook?> openBuilder(
  WidgetTester tester,
  Future<void> Function() act,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  AvatarLook? saved;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            saved = await Navigator.of(context).push<AvatarLook>(
              MaterialPageRoute(
                builder: (_) => AvatarCreatorScreen(
                  initial: const AvatarLook(),
                  catalogue: shipped(),
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
  await act();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  return saved;
}

void main() {
  testWidgets('the shipped loader brings the rig with the catalogue', (
    tester,
  ) async {
    final c = await tester.runAsync(loadAvatarCatalogue);
    expect(c!.rig, isNotNull);
    expect(c.slots, isNot(contains('implant')));
  });

  test('a box is scaled into its target and centred on it', () {
    const box = Rect.fromLTRB(0.1, 0.2, 0.9, 0.6);
    const target = Rect.fromLTWH(0.4, 0.1, 0.2, 0.2);
    final placed = fitRect(box, target);
    final landed = Rect.fromLTWH(
      placed.left + box.left * placed.width,
      placed.top + box.top * placed.height,
      box.width * placed.width,
      box.height * placed.height,
    );
    expect(landed.center.dx, closeTo(target.center.dx, 1e-9));
    expect(landed.center.dy, closeTo(target.center.dy, 1e-9));
    expect(landed.width, closeTo(target.width, 1e-9));
    expect(landed.height, lessThanOrEqualTo(target.height + 1e-9));
    expect(mirrorRect(target).center.dx, closeTo(1 - target.center.dx, 1e-9));
  });

  test('every shipped layer carries a box and every item a placement', () {
    final c = shipped();
    for (final item in c.items) {
      for (final layer in c.layersOf(item)) {
        expect(layer.box?.length, 4, reason: item.id);
      }
      expect(c.rig!.placementOf(item.id), isNotNull, reason: item.id);
    }
  });

  test('default character is a full head and body, nothing optional', () {
    final look = standard(shipped());
    for (final s in ['base', 'head', 'eyes', 'eyebrows', 'nose', 'mouth']) {
      expect(look.picks.containsKey(s), isTrue, reason: s);
    }
    expect(look.picks.containsKey('hair'), isTrue);
    expect(look.picks.containsKey('outfit'), isTrue);
    for (final s in ['beard', 'weapon', 'accessory', 'marks']) {
      expect(look.picks.containsKey(s), isFalse, reason: s);
    }
  });

  test('layers stack body, clothes, head, face, hair, weapon', () {
    final c = shipped();
    final layers = avatarLayers(standard(c, ['weapon.tools-1']), c);
    int z(String part) =>
        layers.firstWhere((l) => l.asset.contains(part)).order;
    expect(z('body-base-full'), lessThan(z('heads-base-grey')));
    expect(z('outfit-vest'), lessThan(z('heads-base-grey')));
    expect(z('heads-base-grey'), lessThan(z('eyes-sheet')));
    expect(z('eyes-sheet'), lessThan(z('hairstyles')));
    expect(z('hairstyles'), lessThan(z('tools-sheet')));
    for (final l in layers) {
      expect(l.placement, isNotNull, reason: l.asset);
    }
  });

  test('paired pieces are drawn twice, the second one mirrored', () {
    final c = shipped();
    final eyes = avatarLayers(
      standard(c),
      c,
    ).where((l) => l.asset.contains('eyes-sheet')).toList();
    expect(eyes.length, 2);
    expect(eyes.where((l) => l.flip).length, 1);
    final left = eyes.firstWhere((l) => !l.flip).placement!;
    final right = eyes.firstWhere((l) => l.flip).placement!;
    expect(left.center.dx + right.center.dx, closeTo(1, 1e-9));
  });

  test('a hood hides the hair, a mask hides mouth, nose and beard', () {
    final c = shipped();
    String assets(AvatarLook l) =>
        avatarLayers(l, c).map((x) => x.asset).join();
    expect(assets(standard(c)).contains('hairstyles'), isTrue);
    expect(
      assets(standard(c, ['outfit.hoods-1'])).contains('hairstyles'),
      isFalse,
    );
    final masked = standard(c, ['accessory.face-masks-1', 'beard.beards-1']);
    expect(c.hiddenSlots(masked), containsAll(['mouth', 'nose', 'beard']));
    expect(assets(masked).contains('lips'), isFalse);
    expect(assets(masked).contains('beards'), isFalse);
    final bearded = assets(standard(c, ['beard.beards-1']));
    expect(bearded.contains('lips') && bearded.contains('beards'), isTrue);
  });

  test('pieces with no placement stay out of the builder', () {
    final c = shipped();
    expect(c.slots, isNot(contains('implant')));
    expect(c.slots.first, 'head');
    expect(c.itemsFor('base').map((i) => i.id), ['base.body-base-full-1']);
    expect(c.itemsFor('outfit').any((i) => i.id.contains('calves')), isFalse);
  });

  test('multi-piece sheets are never offered nor drawn', () {
    final c = shipped();
    final ids = [for (final s in c.slots) ...c.itemsFor(s).map((i) => i.id)];
    for (final id in ['hair.hairstyles-1', 'hair.hairstyles-2', 'head.heads-base-grey-wide-ears-1']) {
      expect(ids, isNot(contains(id)));
    }
    expect(ids, contains('hair.hairstyles-3'));
  });

  test('without a rig the catalogue keeps its legacy behaviour', () {
    final c = shipped(rig: false);
    expect(c.slots.contains('implant'), isTrue);
    final look = standard(c);
    expect(look.picks['hair']!.itemId, 'hair.hairstyles-1');
    expect(look.picks.containsKey('outfit'), isFalse);
  });

  test('randomise gives a full character from placed pieces only', () {
    final c = shipped();
    for (var seed = 0; seed < 20; seed++) {
      final look = randomAvatarLook(c, Random(seed));
      expect(look.picks.containsKey('head'), isTrue);
      expect(look.picks.containsKey('eyes'), isTrue);
      for (final p in look.picks.values) {
        expect(c.rig!.isHidden(p.itemId), isFalse, reason: p.itemId);
      }
    }
    expect(
      randomAvatarLook(c, Random(3)).toJson(),
      randomAvatarLook(c, Random(3)).toJson(),
    );
  });

  testWidgets('a skin colour reaches every skin piece, not the hair', (
    tester,
  ) async {
    final saved = await openBuilder(tester, () async {
      final swatches = find.descendant(
        of: find.byType(AvatarColorRow),
        matching: find.byType(InkWell),
      );
      await tester.tap(swatches.at(2));
      await tester.pump();
    });
    final c = shipped();
    final skin = c.palettes['skin']![2];
    for (final slot in ['base', 'head', 'nose', 'mouth']) {
      expect(saved!.picks[slot]!.color, skin, reason: slot);
    }
    expect(saved!.picks['hair']!.color, isNot(skin));
  });

  testWidgets('the builder opens complete and randomise keeps it complete', (
    tester,
  ) async {
    final saved = await openBuilder(tester, () async {
      await tester.tap(find.byTooltip('Randomize'));
      await tester.pump();
    });
    expect(saved!.picks.containsKey('head'), isTrue);
    expect(saved.picks.containsKey('eyes'), isTrue);
  });
}
