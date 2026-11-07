import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_surface.dart';
import 'package:amiludo/layers/technical/Motion/shake_source.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: app!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: child,
    ),
  ),
);

Future<void> useSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('throw, keep aside and total at $size', (tester) async {
      await useSize(tester, size);
      await tester.pumpWidget(host(const DiceTrayPage(seed: 5)));
      expect(find.byType(DieFace), findsNothing);
      await tester.tap(find.text('Throw'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(find.byType(DieFace), findsNWidgets(2));
      expect(find.textContaining('Total'), findsOneWidget);
      await tester.tap(find.byType(DieFace).first);
      await tester.pump();
      expect(find.text('Kept aside'), findsOneWidget);
      expect(find.byType(DieFace), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a shake throws the dice like the button', (tester) async {
    await useSize(tester, const Size(390, 844));
    final source = ManualShakeSource();
    addTearDown(source.close);
    await tester.pumpWidget(host(DiceTrayPage(seed: 1, shakeSource: source)));
    source.shake();
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(DieFace), findsNWidgets(2));
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('reduced motion settles at once without a running ticker', (
    tester,
  ) async {
    await useSize(tester, const Size(390, 844));
    await tester.pumpWidget(host(const DiceTrayPage(seed: 2), reduced: true));
    await tester.tap(find.text('Throw'));
    await tester.pump();
    expect(find.byType(DieFace), findsNWidgets(2));
    final rest = tester.getCenter(find.byType(DieFace).first);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getCenter(find.byType(DieFace).first), rest);
  });

  testWidgets('adding and removing dice updates the tray', (tester) async {
    await useSize(tester, const Size(390, 844));
    await tester.pumpWidget(host(const DiceTrayPage(seed: 3)));
    await tester.tap(find.text('+ d20'));
    await tester.pump();
    await tester.tap(find.text('Throw'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(DieFace), findsNWidgets(3));
  });
}
