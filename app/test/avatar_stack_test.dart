import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/technical/Avatar/avatar_stack.dart';

void main() {
  test('layers are drawn by ascending order and hidden ones dropped', () {
    final result = orderedLayers(
      const [
        AvatarLayerSpec(order: 9, asset: 'avatar/weapons/a'),
        AvatarLayerSpec(order: 3, asset: 'avatar/bodies/a'),
        AvatarLayerSpec(order: 4, asset: 'avatar/bodies/arm'),
      ],
      {'avatar/bodies/arm'},
    );
    expect(result.map((l) => l.asset), ['avatar/bodies/a', 'avatar/weapons/a']);
  });

  testWidgets('a missing asset never throws and the stack still renders', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AvatarStack(
          layers: [AvatarLayerSpec(order: 1, asset: 'avatar/bodies/none')],
          semanticLabel: 'Character',
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(AvatarStack), findsOneWidget);
  });
}
