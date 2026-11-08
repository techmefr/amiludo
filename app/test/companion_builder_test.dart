import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_session.dart';
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
    await tester.tap(find.text('Qui commence ?'));
    await tester.pumpAndSettle();
    expect(find.text('Qui commence ?'), findsOneWidget);
    await tester.tap(find.text('Lancer la session'));
    await tester.pumpAndSettle();
    expect(find.byType(CompanionSession), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
