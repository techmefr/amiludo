import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_spinner.dart';

void main() {
  for (final sides in const [6, 8, 12, 20]) {
    testWidgets('dragging a d$sides turns to another face', (tester) async {
      final seen = <int>[];
      var current = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, set) => Scaffold(
              body: Center(
                child: DieFaceSpinner(
                  design: DieDesign.standard('a', 'Mine', sides),
                  current: current,
                  size: 220,
                  onFace: (i) {
                    seen.add(i);
                    set(() => current = i);
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.drag(find.byType(DieFaceSpinner), const Offset(120, 40));
      await tester.pumpAndSettle();
      expect(seen, isNotEmpty);
      expect(seen.every((i) => i >= 0 && i < sides), isTrue);
      expect(current, isNot(0));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('choosing a face elsewhere turns the die to it', (tester) async {
    var current = 0;
    late void Function(int) choose;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, set) {
            choose = (i) => set(() => current = i);
            return Scaffold(
              body: DieFaceSpinner(
                design: DieDesign.standard('a', 'Mine', 6),
                current: current,
                onFace: (_) {},
              ),
            );
          },
        ),
      ),
    );
    choose(3);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
