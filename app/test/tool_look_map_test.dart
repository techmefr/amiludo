import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/presentation/map_tool.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/components/parchment_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

void main() {
  test('ink stays readable on parchment', () {
    expect(
      toolContrast(ParchmentPalette.ink, ParchmentPalette.land),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      toolContrast(
        ParchmentPalette.ink,
        Color.lerp(ParchmentPalette.land, ParchmentPalette.relief, .35)!,
      ),
      greaterThanOrEqualTo(4.5),
    );
  });
  for (final size in const [
    Size(390, 844),
    Size(844, 390),
    Size(1280, 720),
    Size(1920, 1080),
  ]) {
    testWidgets('the map is a parchment chart at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = StoreDatabase.forTesting(NativeDatabase.memory());
      configureDependencies(db);
      addTearDown(getIt.reset);
      await tester.pumpWidget(const AmiludoApp());
      await tester.pumpAndSettle();
      router.go('/tools');
      await tester.pumpAndSettle();
      router.push('/tools/map');
      await tester.pumpAndSettle();
      expect(find.byType(MapBoardTool), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    });
  }
}
