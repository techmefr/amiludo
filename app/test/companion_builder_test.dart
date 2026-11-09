import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_session.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_grid.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

void main() {
  test('a brick remembers its tile size and maps to its tool', () {
    const brick = Brick(id: 'life-2', type: 'counter');
    expect(brick.size, TileSize.medium);
    final large = brick.resized(TileSize.large);
    expect(large.size, TileSize.large);
    expect(Brick.fromJson(large.toJson()).size, TileSize.large);
    expect(brick.toolId, 'counter-life');
    expect(const Brick(id: 'x', type: 'hourglass').toolId, 'hourglass');
  });

  test('a brick label and merged settings survive a round trip', () {
    const brick = Brick(id: 'a', type: 'hourglass');
    expect(brick.label, isNull);
    final named = brick.labelled('  Sand  ');
    expect(named.label, 'Sand');
    expect(Brick.fromJson(named.toJson()).label, 'Sand');
    expect(named.labelled(' ').label, isNull);
    final merged = named.resized(TileSize.small).withSettings({'start': 3});
    expect(merged.size, TileSize.small);
    expect(merged.label, 'Sand');
    expect(merged.settings['start'], 3);
  });

  test('the session grid adapts columns and spans to the width', () {
    expect(sessionColumns(390), 1);
    expect(sessionColumns(844), 2);
    expect(sessionColumns(1920), 5);
    expect(sessionTileWidth(844, 2, 1), lessThan(sessionTileWidth(844, 2, 2)));
    expect(sessionTileWidth(390, 1, 2), 390);
    expect(const Brick(id: 'a', type: 'dice').resized(TileSize.large).span, 2);
    expect(const Brick(id: 'a', type: 'dice').span, 1);
  });

  testWidgets('build a companion, add a brick and start the session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    router.go('/build');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter une brique'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Qui commence ?'),
      300,
      scrollable: find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Qui commence ?'));
    await tester.pumpAndSettle();
    expect(find.text('Qui commence ?'), findsOneWidget);
    await tester.tap(find.text('Lancer la session'));
    await tester.pumpAndSettle();
    expect(find.byType(CompanionSession), findsOneWidget);
    await tester.tap(find.text('Réorganiser'));
    await tester.pumpAndSettle();
    expect(find.text('Terminé'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
