import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/tool_catalog.dart';
import 'package:amiludo/layers/functional/Templates/presentation/bricks_stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

void main() {
  testWidgets('chips toggle counter bricks on and off', (tester) async {
    final bricks = <Brick>[];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, set) =>
                BricksStage(bricks: bricks, refresh: set),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Vie'));
    await tester.pump();
    expect(bricks.single.id, 'life');
    expect(bricks.single.type, 'counter');
    await tester.tap(find.text('Vie'));
    await tester.pump();
    expect(bricks, isEmpty);
  });

  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('every brick type is listed and settings apply at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final bricks = <Brick>[];
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, set) =>
                    BricksStage(bricks: bricks, refresh: set),
              ),
            ),
          ),
        ),
      );
      expect(
        find.byType(FilterChip),
        findsNWidgets(brickChoices.length + toolDefinitions.length),
      );
      await tester.tap(find.byType(FilterChip).at(brickChoices.length));
      await tester.pump();
      expect(bricks.single.id, toolDefinitions.first.id);
      expect(bricks.single.type, toolDefinitions.first.id);
      await tester.tap(find.byType(FilterChip).at(brickChoices.length));
      await tester.tap(find.text('Vie'));
      await tester.pump();
      await tester.tap(find.byTooltip('Vie - Réglages de la brique'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Santé');
      await tester.enterText(find.byType(TextField).at(3), '20');
      await tester.tap(find.text('Rouge'));
      await tester.ensureVisible(find.text('Appliquer'));
      await tester.tap(find.text('Appliquer'));
      await tester.pumpAndSettle();
      final settings = bricks.single.settings;
      expect(settings['name'], 'Santé');
      expect(settings['maximum'], 20);
      expect(settings['minimum'], 0);
      expect(settings['color'], 0xFFD94A4A);
      expect(tester.takeException(), isNull);
    });
  }
}
