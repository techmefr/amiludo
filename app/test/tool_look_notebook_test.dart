import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Notebook/presentation/campaign_theme.dart';
import 'package:amiludo/layers/technical/Theme/components/paper_look.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

void main() {
  test('paper and ink stay readable in light and night', () {
    expect(
      toolContrast(PaperPalette.ink, PaperPalette.paper),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      toolContrast(PaperPalette.ink, PaperPalette.margin),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      toolContrast(PaperPalette.nightInk, PaperPalette.night),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('every campaign palette gives readable links on paper', () {
    for (final seed in notebookPalettes) {
      for (final mode in Brightness.values) {
        final theme = paperTheme(ThemeData(brightness: mode), Color(seed));
        expect(
          toolContrast(theme.colorScheme.primary, theme.colorScheme.surface),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });

  testWidgets('the ribbon bookmark is decorative', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RibbonBookmark())),
    );
    expect(find.byType(RibbonBookmark), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
