import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_companion/layers/functional/Random/presentation/random_tool.dart';

void main() {
  testWidgets(
    'wheel respects reduced motion and reveals without a long animation',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MediaQuery(
                data: MediaQueryData(disableAnimations: true),
                child: RandomTool(id: 'wheel', names: ['A', 'B']),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump();
      expect(find.byType(SelectableText), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
