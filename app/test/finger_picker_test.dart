import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

void main() {
  testWidgets('first mode highlights one finger and dims the others', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = StoreDatabase.forTesting(NativeDatabase.memory());
    configureDependencies(db);
    addTearDown(getIt.reset);
    await tester.pumpWidget(const AmiludoApp());
    await tester.pumpAndSettle();
    router.go('/tools/picker');
    await tester.pumpAndSettle();

    final pad = find.byType(FingerRing);
    expect(pad, findsNothing);
    final a = await tester.startGesture(const Offset(120, 300));
    final b = await tester.startGesture(const Offset(260, 420));
    await tester.pump();
    expect(find.byType(FingerRing), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 2));
    final states = tester
        .widgetList<FingerRing>(find.byType(FingerRing))
        .map((r) => r.state)
        .toList();
    expect(states.where((s) => s == FingerRingState.winner), hasLength(1));
    expect(states.where((s) => s == FingerRingState.dim), hasLength(1));
    await a.up();
    await b.up();
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
