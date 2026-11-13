import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_editor_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_spinner.dart';

import 'die_studio_test.dart' show host, studio;

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720), Size(844, 390)]) {
    testWidgets('turn the die, pick a face, change it and save at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final s = studio();
      await tester.pumpWidget(
        host(
          s.cubit,
          DieEditorScreen(initial: DieDesign.standard('a', 'Mine', 6)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Edit face 1'), findsOneWidget);
      await tester.drag(find.byType(DieFaceSpinner), const Offset(110, 0));
      await tester.pumpAndSettle();
      expect(find.text('Edit face 1'), findsNothing);
      final label = find.textContaining('Edit face ');
      expect(label, findsOneWidget);
      final shown = (tester.widget<Text>(label).data!).split(' ').last;
      await tester.tap(label);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'X');
      await tester.tap(find.text('Save').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Save'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final saved = s.library.current.byId('a')!;
      expect(saved.faces[int.parse(shown) - 1].value, 'X');
      expect(tester.takeException(), isNull);
    });
  }
}
