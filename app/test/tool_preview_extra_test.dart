import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/presentation/tool_preview.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('dedicated previews draw in ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      for (final id in const [
        'ranking',
        'stats',
        'turns',
        'bank',
        'auction',
        'clocks',
        'combat',
        'bestiary',
        'sport',
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
            home: Scaffold(body: ToolPreview(id: id)),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull, reason: id);
      }
    });
  }
}
