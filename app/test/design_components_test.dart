import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_tile.dart';
import 'package:amiludo/layers/technical/Theme/components/state_views.dart';
import 'package:amiludo/layers/technical/Theme/deck_theme.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const sizes = [Size(390, 844), Size(1280, 720), Size(1920, 1080)];

Widget host(Brightness brightness, Widget child) => MaterialApp(
  theme: deckTheme(const Appearance(), brightness),
  home: Scaffold(body: child),
);

void main() {
  for (final size in sizes) {
    for (final brightness in Brightness.values) {
      testWidgets('components fit at $size in ${brightness.name}', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var taps = 0;
        await tester.pumpWidget(
          host(
            brightness,
            ListView(
              children: [
                SizedBox(
                  width: 180,
                  child: DeckTile(
                    icon: Icons.casino_outlined,
                    title: 'Dice',
                    subtitle: 'Roll anything',
                    onTap: () => taps++,
                  ),
                ),
                const SizedBox(
                  height: 200,
                  child: DeckLoadingState(label: 'Loading'),
                ),
                SizedBox(
                  height: 220,
                  child: DeckErrorState(message: 'Broken', onRetry: () {}),
                ),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Dice'));
        expect(taps, 1);
        final tile = tester.getSize(find.byType(DeckTile));
        expect(tile.height, greaterThanOrEqualTo(Targets.minimum));
        final retry = tester.getSize(find.byType(OutlinedButton));
        expect(retry.height, greaterThanOrEqualTo(Targets.minimum));
      });
    }
  }

  testWidgets('tile is announced as a selected button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Brightness.light,
        DeckTile(
          icon: Icons.timer_outlined,
          title: 'Timer',
          selected: true,
          onTap: () {},
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(DeckTile)),
      matchesSemantics(
        label: 'Timer',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('sheet opens with its title and content', (tester) async {
    await tester.pumpWidget(
      host(
        Brightness.light,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showDeckSheet<void>(
              context: context,
              title: 'Options',
              builder: (_) => const Text('Body'),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Options'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });
}
