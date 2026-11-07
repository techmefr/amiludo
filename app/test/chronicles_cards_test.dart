import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_card.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_run.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/card_painter.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/portrait_painter.dart';
import 'package:amiludo/layers/functional/Random/presentation/chronicles/table_gestures.dart';
import 'package:amiludo/layers/functional/Random/presentation/cubit/chronicles_cubit.dart';

import 'chronicles_flow_test.dart';

void paintOnce(CustomPainter painter) {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), const Size(200, 280));
  recorder.endRecording().dispose();
}

Future<ChroniclesCubitHarness> openTable(
  WidgetTester tester,
  Size size, {
  bool still = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final runs = MemoryRuns();
  final cubit = cubitFor(runs, 21);
  addTearDown(cubit.close);
  await cubit.load();
  await cubit.start('fantasy');
  if (still) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(host(cubit));
  await tester.pumpAndSettle();
  return ChroniclesCubitHarness(cubit);
}

class ChroniclesCubitHarness {
  ChroniclesCubitHarness(this.cubit);
  final ChroniclesCubit cubit;
  ChroniclesRun get run => cubit.state.run as ChroniclesRun;
}

Future<void> faceUp(WidgetTester tester) async {
  if (has('flip')) await tapKey(tester, 'flip');
}

void main() {
  test('swipe and tear thresholds follow the table width', () {
    expect(swipeOutcome(100, 300), SwipeOutcome.keep);
    expect(swipeOutcome(-100, 300), SwipeOutcome.pass);
    expect(swipeOutcome(5, 300), SwipeOutcome.tap);
    expect(swipeOutcome(50, 300), SwipeOutcome.none);
    expect(boosterOutcome(140, 400), BoosterOutcome.tear);
    expect(boosterOutcome(60, 400), BoosterOutcome.previous);
    expect(boosterOutcome(-60, 400), BoosterOutcome.next);
    expect(boosterOutcome(10, 400), BoosterOutcome.none);
    expect(tableHeight(const Size(390, 844)), closeTo(844 * 0.54, 0.01));
  });

  test('painters draw every rarity without error', () {
    for (var score = 1; score <= 6; score++) {
      paintOnce(
        ChroniclesCardPainter(
          id: 'card-$score',
          score: score,
          surface: const Color(0xffffffff),
        ),
      );
    }
    paintOnce(
      const PortraitPainter(
        ChroniclesAppearance(
          skin: '#d9a679',
          hair: '#1e1b18',
          build: 'robuste',
        ),
        Color(0xff999999),
        Color(0xff000000),
      ),
    );
    expect(parseHex('nope', const Color(0xff000000)), const Color(0xff000000));
  });

  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('swipe right keeps and swipe left passes at $size', (
      tester,
    ) async {
      final h = await openTable(tester, size);
      await h.cubit.openBooster('fer');
      await tester.pumpAndSettle();
      await faceUp(tester);
      final first = h.run.current!.id;
      await tester.drag(
        find.byKey(ValueKey('table-$first')),
        Offset(size.width, 0),
      );
      await tester.pumpAndSettle();
      expect(h.run.kept.map((k) => k.card.id), contains(first));
      await faceUp(tester);
      final second = h.run.current;
      if (second != null) {
        await tester.drag(
          find.byKey(ValueKey('table-${second.id}')),
          Offset(-size.width, 0),
        );
        await tester.pumpAndSettle();
        expect(h.run.kept.map((k) => k.card.id), isNot(contains(second.id)));
        expect(h.run.current?.id, isNot(second.id));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tap opens the detail panel at $size', (tester) async {
      final h = await openTable(tester, size);
      await h.cubit.openBooster('vent');
      await tester.pumpAndSettle();
      await faceUp(tester);
      await tester.tap(find.byKey(ValueKey('table-${h.run.current!.id}')));
      await tester.pumpAndSettle();
      expect(has('close-detail'), isTrue);
      await tapKey(tester, 'close-detail');
      expect(has('close-detail'), isFalse);
    });

    testWidgets('a long drag on the booster tears it at $size', (tester) async {
      final h = await openTable(tester, size);
      final table = find.byKey(const ValueKey('booster-table'));
      await tester.drag(table, Offset(tester.getSize(table).width * 0.6, 0));
      await tester.pumpAndSettle();
      expect(h.run.phase, ChroniclesPhase.discover);
    });

    testWidgets('a short drag changes the edition at $size', (tester) async {
      final h = await openTable(tester, size);
      final table = find.byKey(const ValueKey('booster-table'));
      await tester.drag(table, const Offset(-90, 0));
      await tester.pumpAndSettle();
      expect(h.run.phase, ChroniclesPhase.edition);
      expect(find.text('Vent'), findsWidgets);
    });

    testWidgets('reduced motion still plays at $size', (tester) async {
      final h = await openTable(tester, size, still: true);
      await h.cubit.openBooster('esprit');
      await tester.pumpAndSettle();
      await faceUp(tester);
      await tapKey(tester, 'keep');
      expect(h.run.kept, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
