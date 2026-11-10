import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/dependencies.dart';
import 'package:amiludo/layers/functional/Appearance/domain/use_cases/change_appearance_use_case.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Storage/store_database.dart';
import 'package:amiludo/main.dart';
import 'package:amiludo/router.dart';

import 'contrast_sampler.dart';

const _routes = String.fromEnvironment('ROUTES', defaultValue: '');
const _only = String.fromEnvironment('SKINS', defaultValue: '');
const _skins = ['clean', 'play', 'cyber', 'orbital', 'paper', 'game'];
const _full = bool.fromEnvironment('FULL');
const _palettes = _full
    ? ['clean', 'acid', 'honey', 'plasma']
    : ['clean', 'acid'];
const _sizes = _full ? [Size(375, 812), Size(800, 900)] : [Size(375, 812)];
const _screens = [
  '/',
  '/tools',
  '/tools?category=time',
  '/tools?category=chance',
  '/tools?category=scores',
  '/tools?category=cards',
  '/tools?category=rules',
  '/tools?category=votes',
  '/tools?category=gm',
  '/tools?category=players',
  '/tools/dice-tray',
  '/tools/wheel',
  '/tools/coin',
  '/tools/picker',
  '/tools/scores',
  '/tools/hourglass',
  '/tools/combat',
  '/templates',
  '/library',
  '/friends',
  '/history',
  '/appearance',
];

Future<List<String>> _audit(
  WidgetTester tester,
  Size size,
  Appearance appearance,
  List<String> routes,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = StoreDatabase.forTesting(NativeDatabase.memory());
  configureDependencies(db);
  final key = GlobalKey();
  router.go('/');
  await tester.pumpWidget(RepaintBoundary(key: key, child: const AmiludoApp()));
  await tester.pumpAndSettle();
  await getIt<ChangeAppearanceUseCase>()(appearance);
  await tester.pumpAndSettle();
  final out = <String>[];
  for (final route in routes) {
    router.go(route);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    tester.takeException();
    final pixels = await capture(tester, key);
    out.addAll(
      contrastFailures(
        pixels,
        visibleTexts(tester, size),
        '$route ${appearance.skin}/${appearance.palette}/${appearance.mode}',
      ),
    );
  }
  await tester.pumpWidget(const SizedBox());
  await db.close();
  await getIt.reset();
  return out;
}

void main() {
  testWidgets('text stays AA over what is painted behind it', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
          (call) async => null,
        );
    final report = <String>[];
    final routes = _routes.isEmpty ? _screens : _routes.split(',');
    for (final size in _sizes) {
      for (final skin in _skins) {
        for (final palette in _palettes) {
          if (_only.isNotEmpty && !_only.split(',').contains(skin)) continue;
          for (final mode in const ['light', 'dark']) {
            report.addAll(
              await _audit(
                tester,
                size,
                Appearance(skin: skin, palette: palette, mode: mode),
                routes,
              ),
            );
          }
        }
      }
    }
    expect(report, isEmpty, reason: report.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 30)));
}
