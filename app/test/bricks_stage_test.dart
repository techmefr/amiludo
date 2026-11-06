import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
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
        home: StatefulBuilder(
          builder: (context, set) =>
              BricksStage(bricks: bricks, refresh: set),
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
}
