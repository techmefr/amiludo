import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_tile.dart';
import 'package:amiludo/layers/technical/Theme/components/hud_bar.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';

const game = Appearance(
  skin: 'game',
  palette: 'gold',
  mode: 'dark',
  shape: 'square',
  font: 'Rajdhani',
);

double _channel(int value) {
  final c = value / 255;
  return c <= .03928 ? c / 12.92 : pow((c + .055) / 1.055, 2.4).toDouble();
}

double _luminance(Color color) =>
    .2126 * _channel((color.r * 255).round()) +
    .7152 * _channel((color.g * 255).round()) +
    .0722 * _channel((color.b * 255).round());

double contrast(Color a, Color b) {
  final hi = max(_luminance(a), _luminance(b));
  final lo = min(_luminance(a), _luminance(b));
  return (hi + .05) / (lo + .05);
}

Widget host(Appearance appearance, Widget child, {bool still = false}) =>
    MaterialApp(
      theme: deckTheme(appearance, Brightness.light),
      darkTheme: deckTheme(appearance, Brightness.dark),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: still),
          child: Scaffold(body: child),
        ),
      ),
    );

void main() {
  test('game appearance survives a JSON round trip', () {
    final restored = Appearance.fromJson(game.toJson());
    expect(restored.skin, 'game');
    expect(restored.palette, 'gold');
    expect(Appearance.palettes, contains('gold'));
  });

  test('game skin and gold palette meet WCAG AA in both brightnesses', () {
    for (final brightness in Brightness.values) {
      final theme = deckTheme(game, brightness);
      final scheme = theme.colorScheme;
      final background = theme.scaffoldBackgroundColor;
      expect(contrast(scheme.onSurface, background), greaterThanOrEqualTo(4.5));
      expect(
        contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(contrast(scheme.primary, background), greaterThanOrEqualTo(4.5));
      expect(
        contrast(scheme.onSecondary, scheme.secondary),
        greaterThanOrEqualTo(4.5),
      );
      expect(contrast(scheme.outline, background), greaterThanOrEqualTo(3));
    }
  });

  test('gold palette text pairs meet WCAG AA in light and dark', () {
    final p = DeckPalette.values['gold']!;
    expect(contrast(Color(p.ink), Color(p.background)), greaterThan(4.5));
    expect(
      contrast(Color(p.darkInk), Color(p.darkBackground)),
      greaterThan(4.5),
    );
    expect(
      contrast(Color(p.darkBackground), Color(p.accent)),
      greaterThan(4.5),
    );
    expect(
      contrast(Color(p.signal), Color(p.darkBackground)),
      greaterThan(4.5),
    );
  });

  test(
    'game tokens are chunky and glowing while other skins are unchanged',
    () {
      final style = deckTheme(game, Brightness.light).extension<DeckStyle>()!;
      expect(style.borderWidth, 3);
      expect(style.glow, isNotNull);
      for (final skin in ['play', 'cyber', 'orbital', 'paper']) {
        final other = deckTheme(
          Appearance(skin: skin),
          Brightness.light,
        ).extension<DeckStyle>()!;
        expect(other.borderWidth, 1, reason: skin);
        expect(other.glow, isNull, reason: skin);
      }
      expect(
        deckTheme(const Appearance(), Brightness.light).brightness,
        Brightness.light,
      );
    },
  );

  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('game skin renders tiles, buttons and bar at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var taps = 0;
      await tester.pumpWidget(
        host(
          game,
          ListView(
            children: [
              DeckTile(
                icon: Icons.casino_outlined,
                title: 'Dice',
                subtitle: 'Roll anything',
                selected: true,
                onTap: () => taps++,
              ),
              FilledButton(onPressed: () => taps++, child: const Text('Go')),
              const Card(child: Text('Card')),
              const HudBar(value: .5, label: 'Health'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Dice'));
      await tester.tap(find.text('Go'));
      expect(taps, 2);
      final semantics = tester.getSemantics(find.byType(HudBar));
      expect(semantics.label, 'Health');
      expect(semantics.value, '50%');
      final context = tester.element(find.byType(Scaffold));
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        Color(DeckPalette.values['gold']!.darkBackground),
      );
    });
  }

  testWidgets('health bar jumps without animation when motion is reduced', (
    tester,
  ) async {
    Widget bar(double value) =>
        host(game, HudBar(value: value, label: 'Health'), still: true);
    await tester.pumpWidget(bar(.2));
    await tester.pumpWidget(bar(.8));
    await tester.pump();
    final fill = tester.widget<AnimatedFractionallySizedBox>(
      find.byType(AnimatedFractionallySizedBox),
    );
    expect(fill.duration, Duration.zero);
    expect(fill.widthFactor, .8);
  });
}
