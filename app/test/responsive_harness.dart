import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

const responsiveSizes = [
  Size(320, 568),
  Size(390, 844),
  Size(768, 1024),
  Size(1280, 720),
  Size(1920, 1080),
];

const responsiveScales = [1.0, 1.5];

Future<void> expectRoutesFit(
  WidgetTester tester,
  Size size,
  double scale,
  Iterable<String> routes,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  addTearDown(getIt.reset);
  await tester.pumpWidget(const AmiludoApp());
  await tester.pumpAndSettle();
  for (final route in routes) {
    router.go('/');
    await tester.pumpAndSettle();
    router.push(route);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '$route at $size x$scale');
  }
  await tester.pumpWidget(const SizedBox());
  await db.close();
}
