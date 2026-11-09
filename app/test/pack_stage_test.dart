import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/fan_card.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/opening_pack.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_idle.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_stage.dart';

Widget host(double width, Widget child, {bool reduced = false}) => MediaQuery(
  data: MediaQueryData(size: Size(width, 800), disableAnimations: reduced),
  child: MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  ),
);

PackStage stage({VoidCallback? onDone, bool autoOpen = false}) => PackStage(
  rarities: const [.1, .5, 1],
  packLabel: 'open pack',
  cardLabel: 'reveal card',
  autoOpen: autoOpen,
  onDone: onDone,
  faceBuilder: (i, w) => SizedBox(width: w, child: Text('face $i')),
);

void main() {
  for (final width in [375.0, 768.0, 1280.0]) {
    testWidgets('full sequence works at width ${width.toInt()}', (
      tester,
    ) async {
      var done = false;
      await tester.pumpWidget(host(width, stage(onDone: () => done = true)));
      expect(find.byType(PackIdle), findsOneWidget);
      expect(find.byType(FanCard), findsNothing);

      await tester.tap(find.byType(PackIdle));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(OpeningPack), findsOneWidget);
      expect(find.byType(PackIdle), findsNothing);

      await tester.pump(const Duration(milliseconds: 2400));
      expect(find.byType(OpeningPack), findsNothing);
      expect(find.byType(FanCard), findsNWidgets(3));
      expect(tester.takeException(), isNull);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(ValueKey('fan-card-$i')));
        await tester.pump(const Duration(milliseconds: 600));
      }
      expect(done, isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(done, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('autoOpen starts the tear without a tap', (tester) async {
    await tester.pumpWidget(host(375, stage(autoOpen: true)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(OpeningPack), findsOneWidget);
    expect(find.byType(PackIdle), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('reduced motion skips straight to the fanned cards', (
    tester,
  ) async {
    await tester.pumpWidget(host(375, stage(), reduced: true));
    await tester.pump();
    expect(find.byType(PackIdle), findsNothing);
    expect(find.byType(OpeningPack), findsNothing);
    expect(find.byType(FanCard), findsNWidgets(3));
    await tester.tap(find.byKey(const ValueKey('fan-card-1')));
    await tester.pump();
    expect(find.text('face 1'), findsWidgets);
  });

  testWidgets('a revealed card cannot be flipped twice', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      host(
        375,
        FanCard(
          width: 100,
          rarity: 1,
          label: 'x',
          front: const Text('front'),
          onRevealed: () => count++,
        ),
      ),
    );
    await tester.tap(find.byType(FanCard));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(FanCard));
    await tester.pump(const Duration(seconds: 2));
    expect(count, 1);
  });
}
