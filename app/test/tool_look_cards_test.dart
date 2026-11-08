import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Theme/components/pack_burst.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_face.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_flip.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

Widget host(Widget child, {bool reduce = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduce),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  test('roman numerals follow the standard notation', () {
    expect(romanNumeral(4), 'IV');
    expect(romanNumeral(19), 'XIX');
    expect(romanNumeral(1994), 'MCMXCIV');
  });

  test('tarot styles keep readable ink on their paper', () {
    for (final s in TarotStyle.values) {
      expect(toolContrast(s.ink, s.paper), greaterThanOrEqualTo(4.5));
      expect(toolContrast(s.bandInk, s.bandColor), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('every back style keeps the tall tarot ratio', (tester) async {
    for (final s in TarotStyle.values) {
      await tester.pumpWidget(host(TarotBack(style: s, width: 140)));
      final size = tester.getSize(find.byType(TarotBack));
      expect(size.width / size.height, closeTo(tarotRatio, .001));
    }
  });

  testWidgets('face carries title, numeral and description', (tester) async {
    await tester.pumpWidget(
      host(const TarotFace(title: 'Sun', number: 19, description: 'Warmth')),
    );
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('XIX'), findsOneWidget);
    expect(find.text('Warmth'), findsOneWidget);
  });

  testWidgets('flip shows the back then the front', (tester) async {
    Widget flip(bool flipped) => host(
      TarotFlip(
        flipped: flipped,
        back: const SizedBox(key: Key('back'), width: 10, height: 10),
        front: const SizedBox(key: Key('front'), width: 10, height: 10),
      ),
    );
    await tester.pumpWidget(flip(false));
    expect(find.byKey(const Key('back')), findsOneWidget);
    await tester.pumpWidget(flip(true));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('front')), findsOneWidget);
  });

  testWidgets('pack burst ends with the rare card face up', (tester) async {
    var done = false;
    await tester.pumpWidget(
      host(
        PackBurst(
          count: 3,
          rareIndex: 1,
          onDone: () => done = true,
          faceBuilder: (i, w) => TarotFace(title: 'Card $i', width: w),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));
    expect(done, isTrue);
    expect(find.text('Card 1'), findsOneWidget);
  });

  testWidgets('pack burst skips the show when motion is reduced', (
    tester,
  ) async {
    var done = false;
    await tester.pumpWidget(
      host(
        reduce: true,
        PackBurst(
          count: 2,
          rareIndex: 0,
          onDone: () => done = true,
          faceBuilder: (i, w) => TarotFace(title: 'Card $i', width: w),
        ),
      ),
    );
    await tester.pump();
    expect(done, isTrue);
  });
}
