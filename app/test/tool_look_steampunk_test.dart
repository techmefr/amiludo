import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Theme/components/card_skin_face.dart';
import 'package:amiludo/layers/technical/Theme/components/steampunk_face.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_face.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  test('steampunk ink is readable on the parchment panel', () {
    expect(
      toolContrast(steampunkInk, const Color(0xffe9d6a8)),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('steampunk face keeps the frame ratio and shows its text', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const SteampunkFace(title: 'Gearwright', description: 'Builds')),
    );
    final size = tester.getSize(find.byType(SteampunkFace));
    expect(size.width / size.height, closeTo(steampunkRatio, .001));
    expect(find.text('Gearwright'), findsOneWidget);
    expect(find.text('Builds'), findsOneWidget);
  });

  testWidgets('skin switch picks the tarot or steampunk face', (tester) async {
    await tester.pumpWidget(host(const CardSkinFace(title: 'A')));
    expect(find.byType(TarotFace), findsOneWidget);
    await tester.pumpWidget(
      host(const CardSkinFace(title: 'A', skin: CardSkin.steampunk)),
    );
    expect(find.byType(SteampunkFace), findsOneWidget);
  });
}
