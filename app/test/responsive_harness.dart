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
  final failures = <String>[];
  final previous = FlutterError.onError;
  var current = '';
  FlutterError.onError = (details) =>
      failures.add('$current: ${_summary(details)}');
  for (final route in routes) {
    current = route;
    router.go('/');
    await tester.pumpAndSettle();
    router.push(route);
    await tester.pumpAndSettle();
  }
  FlutterError.onError = previous;
  await tester.pumpWidget(const SizedBox());
  await db.close();
  expect(failures, isEmpty, reason: 'at $size x$scale');
}

String _summary(FlutterErrorDetails details) {
  final text = details.toString();
  final first = '${details.exception}'.split('\n').first;
  final where = RegExp(
    r'lib/layers/[\w/]+\.dart:\d+',
  ).allMatches(text).map((m) => m[0]).toSet();
  return '$first ${where.take(3).join(' ')}';
}
