import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/life_match.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_palette.dart';
import 'package:amiludo/layers/technical/Theme/components/color_slab.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

void main() {
  test('panel colours keep white ink readable', () {
    for (final c in panelTints) {
      expect(toolContrast(slabInk, c), greaterThanOrEqualTo(4.5));
    }
  });

  test('resetPlayer restores one player to the starting life', () {
    final match = LifeMatch.begin(['A', 'B']).life(0, -7).life(1, 3);
    final reset = match.resetPlayer(0);
    expect(reset.players[0].life, match.start);
    expect(reset.players[1].life, match.players[1].life);
  });

  testWidgets('colour slab shows its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: ColorSlab(color: Color(0xff1b7f4b), child: Text('20')),
        ),
      ),
    );
    expect(find.text('20'), findsOneWidget);
  });
}
