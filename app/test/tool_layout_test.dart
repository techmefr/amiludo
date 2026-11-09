import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_face.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/tools_home.dart';
import 'package:amiludo/layers/technical/Motion/coin_toss.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';

const sizes = [Size(375, 812), Size(768, 1024), Size(1280, 720)];

Future<void> pumpTool(
  WidgetTester tester,
  Size size,
  Widget tool, {
  bool reduced = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: reduced),
        child: FullPage(
          title: 'tool',
          tool: 'number',
          immersive: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [tool],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final size in sizes) {
    group('immersive tool layout at ${size.width.toInt()}', () {
      for (final id in ['number', 'wheel', 'bag', 'order']) {
        testWidgets('$id has a full-width centred primary action', (
          tester,
        ) async {
          await pumpTool(
            tester,
            size,
            RandomTool(id: id, names: const ['A', 'B']),
          );
          final button = tester.getRect(find.byType(FilledButton).first);
          final content = min(size.width, ToolLayout.maxWidthFor(size.width));
          expect(button.width, greaterThan(content * .75));
          expect((button.center.dx - size.width / 2).abs(), lessThan(2));
          final fields = find.byType(TextField);
          final first = fields.evaluate().isEmpty
              ? tester.getRect(find.byType(FilledButton).first)
              : tester.getRect(fields.first);
          expect(first.top, greaterThanOrEqualTo(toolBackClearance));
          await tester.pumpWidget(const SizedBox());
        });
      }

      testWidgets('number result is large and centred', (tester) async {
        await pumpTool(tester, size, const RandomTool(id: 'number', names: []));
        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        final result = tester.getRect(find.byType(SelectableText));
        expect((result.center.dx - size.width / 2).abs(), lessThan(2));
        final style = tester.widget<SelectableText>(
          find.byType(SelectableText),
        );
        expect(style.style!.fontSize, greaterThan(50));
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('coin lands on the face that matches the result', (
        tester,
      ) async {
        await pumpTool(
          tester,
          size,
          CoinTool(random: RandomTools(random: Random(7))),
        );
        await tester.tap(find.byType(FilledButton).first);
        await tester.pump(const Duration(milliseconds: 500));
        final mid = tester.widgetList<CoinFace>(find.byType(CoinFace)).length;
        expect(mid, 1);
        await tester.pumpAndSettle();
        final face = tester.widget<CoinFace>(find.byType(CoinFace));
        final label = face.heads ? 'HEADS' : 'TAILS';
        expect(find.text(label), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('category list cards fill the width', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ToolsHome(
                  favorites: const [],
                  lastTool: null,
                  onOpen: (_) {},
                  onFavorite: (_) {},
                  onMove: (_, _) {},
                  onCategory: (_) {},
                  category: 'chance',
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        final width = tester.getSize(find.byType(ToolsHome)).width;
        final cards = find.byKey(const ValueKey('coin'));
        final card = tester.getRect(cards);
        if (size.width < 600) expect(card.width, greaterThan(width * .95));
        expect(card.width, greaterThan(200));
        await tester.pumpWidget(const SizedBox());
      });
    });
  }

  test('coin toss lands on the requested face', () {
    for (final heads in [true, false]) {
      final toss = CoinToss(heads: heads, turns: 5);
      expect(toss.showsHeads(1), heads);
      expect(toss.lift(0), 0);
      expect(toss.lift(.4), greaterThan(.5));
      expect(toss.lift(1), closeTo(0, 1e-9));
    }
  });

  testWidgets('reduced motion flips quickly without a toss', (tester) async {
    await pumpTool(
      tester,
      sizes.first,
      CoinTool(random: RandomTools(random: Random(2))),
      reduced: true,
    );
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.byType(CoinFace), findsOneWidget);
    final face = tester.widget<CoinFace>(find.byType(CoinFace));
    expect(find.text(face.heads ? 'HEADS' : 'TAILS'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
