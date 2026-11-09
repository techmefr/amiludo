import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/generator_content.dart';
import 'package:amiludo/layers/functional/Random/presentation/generator_card.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const sheet = GeneratedSheet('Old Bram', [
  GeneratedSection('Trait', ['Grumpy', 'Loyal']),
]);

Widget host(String id, Brightness brightness) => MaterialApp(
  theme: ThemeData(brightness: brightness),
  home: Scaffold(
    body: SingleChildScrollView(child: GeneratorCard(id: id, sheet: sheet)),
  ),
);

void main() {
  testWidgets('every generator card shows its sheet in both themes', (
    tester,
  ) async {
    for (final id in generatorGlyphs.keys) {
      for (final b in Brightness.values) {
        await tester.pumpWidget(host(id, b));
        expect(find.text('Old Bram'), findsOneWidget);
        expect(find.text('Grumpy'), findsOneWidget);
      }
    }
  });

  testWidgets('generator accents keep readable ink on the card', (
    tester,
  ) async {
    for (final id in generatorGlyphs.keys) {
      for (final b in Brightness.values) {
        await tester.pumpWidget(host(id, b));
        final context = tester.element(find.byType(GeneratorCard));
        final tool = toolThemeFor(id);
        final surface = tool.surface(context, mix: .14);
        expect(
          toolContrast(tool.ink(surface), surface),
          greaterThanOrEqualTo(4.5),
          reason: '$id $b',
        );
      }
    }
  });
}
