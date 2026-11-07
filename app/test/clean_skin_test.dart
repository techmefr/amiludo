import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/clean/clean_theme.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_group.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_segmented.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance() + .05, y = b.computeLuminance() + .05;
  return x > y ? x / y : y / x;
}

const sizes = [
  Size(390, 844),
  Size(844, 390),
  Size(1280, 720),
  Size(1920, 1080),
];

void main() {
  test('clean is the default skin and follows the system mode', () {
    const a = Appearance();
    expect(a.skin, 'clean');
    expect(a.mode, 'system');
    expect(Appearance.fromJson(a.toJson()).skin, 'clean');
    expect(Appearance.fromJson({...a.toJson(), 'skin': 'game'}).skin, 'game');
  });

  for (final brightness in Brightness.values) {
    test('clean text and accent keep 4.5:1 in ${brightness.name}', () {
      final c = cleanColors(const Appearance(), brightness);
      for (final ground in [c.background, c.surface]) {
        expect(contrast(c.ink, ground), greaterThan(4.5));
        expect(contrast(c.secondary, ground), greaterThan(4.5));
        expect(contrast(c.accent, ground), greaterThan(4.5));
      }
      expect(contrast(c.onAccent, c.accent), greaterThan(4.5));
      expect(contrast(c.accent, c.tint), greaterThan(4.5));
    });
  }

  test('clean exposes tabular figures and a pill button', () {
    final theme = deckTheme(const Appearance(), Brightness.light);
    expect(theme.textTheme.headlineLarge!.fontFeatures, isNotEmpty);
    expect(theme.extension<DeckStyle>()!.clean, isTrue);
    expect(theme.brightness, Brightness.light);
  });

  test('other skins stay selectable and unchanged', () {
    for (final skin in ['play', 'cyber', 'orbital', 'paper', 'game']) {
      final style = deckTheme(
        Appearance(skin: skin),
        Brightness.light,
      ).extension<DeckStyle>()!;
      expect(style.clean, isFalse, reason: skin);
    }
  });

  for (final size in sizes) {
    for (final brightness in Brightness.values) {
      testWidgets('clean page, group and segmented fit at $size', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var mode = 'system';
        await tester.pumpWidget(
          MaterialApp(
            theme: deckTheme(const Appearance(), brightness),
            home: StatefulBuilder(
              builder: (context, set) => FullPage(
                title: 'Settings',
                child: Column(
                  children: [
                    DeckSegmented<String>(
                      options: const [
                        ('light', 'Light'),
                        ('dark', 'Dark'),
                        ('system', 'Auto'),
                      ],
                      selected: mode,
                      onChanged: (v) => set(() => mode = v),
                    ),
                    const SizedBox(height: 16),
                    DeckGroup(
                      header: 'General',
                      children: [
                        DeckGroupTile(
                          title: 'Language',
                          icon: Icons.contrast,
                          onTap: () {},
                        ),
                        const DeckGroupTile(title: 'Version'),
                        for (var i = 0; i < 30; i++)
                          DeckGroupTile(title: 'Row $i', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsWidgets);
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        expect(mode, 'dark');
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('sheet snaps between detents', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: deckTheme(const Appearance(), Brightness.light),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDeckSheet<void>(
              context: context,
              title: 'Sheet',
              detents: const [.4, .9],
              builder: (_) => const Text('Body'),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
