import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/presentation/coin_customization.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_face.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_tool.dart';

import 'die_studio_test.dart' show host, studio, useSize;

void main() {
  testWidgets('both coin faces can be edited and persist when reopening', (
    tester,
  ) async {
    useSize(tester, const Size(390, 844));
    final s = studio();
    Widget page(Key key) => host(
      s.cubit,
      Scaffold(
        key: key,
        body: const SingleChildScrollView(child: CoinTool()),
      ),
    );
    await tester.pumpWidget(page(const ValueKey(1)));
    for (final (side, label) in [('HEADS', 'Moon'), ('TAILS', 'Sun')]) {
      await tester.tap(find.byTooltip('Faces'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(side));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text or number'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), label);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }
    final saved = s.library.current.byId(coinDesignId);
    expect(saved?.faces.map((face) => face.value), ['Moon', 'Sun']);
    await tester.pumpWidget(page(const ValueKey(2)));
    await tester.pumpAndSettle();
    expect(tester.widget<CoinFace>(find.byType(CoinFace)).face?.value, 'Moon');
    expect(tester.takeException(), isNull);
  });
}
