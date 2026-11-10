import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/use_cases/save_evening_use_case.dart';
import 'package:amiludo/layers/functional/Evenings/presentation/evening_detail.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

Future<void> _open(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  addTearDown(db.close);
  await tester.pumpWidget(const AmiludoApp());
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => getIt<SaveEveningUseCase>()(
      Evening(
        id: 'e1',
        code: 'ABCDEFGH',
        title: 'Soirée Skull',
        startsAt: DateTime.utc(2030, 11, 20, 19),
        hostName: 'Camille',
        seats: 3,
        mine: true,
      ),
    ),
  );
}

void main() {
  testWidgets('wide screens list the nights beside the open one', (
    tester,
  ) async {
    await _open(tester, const Size(1280, 720));
    router.go('/evenings');
    await tester.pumpAndSettle();
    expect(find.byType(EveningDetailPane), findsOneWidget);
    expect(find.text('Soirée Skull'), findsWidgets);
    router.go('/evenings/e1');
    await tester.pumpAndSettle();
    expect(find.byType(EveningDetailPane), findsOneWidget);
    expect(find.byType(EveningDetail), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('narrow screens keep the list and the detail apart', (
    tester,
  ) async {
    await _open(tester, const Size(800, 600));
    router.go('/evenings');
    await tester.pumpAndSettle();
    expect(find.byType(EveningDetailPane), findsNothing);
    router.go('/evenings/e1');
    await tester.pumpAndSettle();
    expect(find.byType(EveningDetail), findsOneWidget);
    expect(find.byType(EveningDetailPane), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
