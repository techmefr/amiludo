import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_surface.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';

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

Future<void> settleDice(WidgetTester tester) async {
  for (var i = 0; i < 700; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void useSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    testWidgets('throw plays sound and keeps the Throw button at $size', (
      tester,
    ) async {
      useSize(tester, size);
      final out = RecordingSoundOutput();
      await tester.pumpWidget(
        host(DiceTrayPage(seed: 5, soundOutput: out, sound: true)),
      );
      await tester.tap(find.text('Throw'));
      await tester.pump();
      await settleDice(tester);
      expect(find.byType(DieFace), findsNWidgets(2));
      expect(out.played.length, greaterThan(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a motion throw and a tilt move the dice at $size', (
      tester,
    ) async {
      useSize(tester, size);
      final motion = ManualTrayMotion();
      addTearDown(motion.close);
      await tester.pumpWidget(host(DiceTrayPage(seed: 3, motion: motion)));
      motion.throwWith(1);
      await tester.pump();
      await settleDice(tester);
      final rest = tester.getCenter(find.byType(DieFace).first);
      motion.tilt(const Tilt(-0.9, 0));
      await tester.pump();
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final moved = tester.getCenter(find.byType(DieFace).first);
      expect(moved.dx, lessThanOrEqualTo(rest.dx));
      await settleDice(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduced motion ignores tilt but still plays sound', (
    tester,
  ) async {
    useSize(tester, const Size(390, 844));
    final out = RecordingSoundOutput();
    final motion = ManualTrayMotion();
    addTearDown(motion.close);
    await tester.pumpWidget(
      host(
        DiceTrayPage(seed: 2, motion: motion, soundOutput: out, sound: true),
        reduced: true,
      ),
    );
    await tester.tap(find.text('Throw'));
    await tester.pump();
    expect(out.played, isNotEmpty);
    final rest = tester.getCenter(find.byType(DieFace).first);
    motion.tilt(const Tilt(-0.9, 0));
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.getCenter(find.byType(DieFace).first), rest);
  });

  testWidgets('choosing a surface is remembered in the settings', (
    tester,
  ) async {
    useSize(tester, const Size(390, 844));
    String? saved;
    await tester.pumpWidget(
      host(DiceTrayPage(seed: 1, onChanged: (s) => saved = s.surface)),
    );
    await tester.tap(find.text('Glass'));
    await tester.pump();
    expect(saved, 'glass');
    await tester.tap(find.text('+ d20'));
    await tester.pump();
    expect(saved, 'glass');
  });
}
