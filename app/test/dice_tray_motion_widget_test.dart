import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/presentation/dice_scene_layers.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_surface.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';

Widget host(Widget child, {bool reduced = false, bool fullscreen = false}) =>
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: app!,
      ),
      home: Scaffold(
        body: fullscreen
            ? child
            : SingleChildScrollView(
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

  testWidgets('3D permission enables shaking and resize preserves the dice', (
    tester,
  ) async {
    useSize(tester, const Size(320, 568));
    final motion = ManualTrayMotion();
    addTearDown(motion.close);
    final results = <int>[];
    await tester.pumpWidget(
      host(
        DiceTrayPage(
          seed: 7,
          solid: true,
          motion: motion,
          requestMotionAccess: () async => true,
          onSettled: results.add,
        ),
        reduced: true,
      ),
    );
    motion.throwWith(1);
    await tester.pump();
    expect(results, isEmpty);
    await tester.tap(find.text('Motion sensors'));
    await tester.pumpAndSettle();
    motion.throwWith(1);
    await tester.pumpAndSettle();
    expect(results, hasLength(1));
    final before = tester.widget<DiceSceneLayers>(find.byType(DiceSceneLayers));
    expect(before.run.values, before.session.values);
    final scene = find.byType(DiceSceneLayers);
    final button = find.text('Throw');
    expect(
      tester.getTopLeft(button).dy,
      greaterThan(tester.getBottomLeft(scene).dy),
    );

    tester.view.physicalSize = const Size(568, 320);
    await tester.pumpAndSettle();
    final after = tester.widget<DiceSceneLayers>(find.byType(DiceSceneLayers));
    expect(after.run.values, before.session.values);
    expect(
      tester.getTopLeft(button).dx,
      greaterThan(tester.getTopRight(scene).dx),
    );
    expect(results, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fullscreen 3D rolls on tap and keeps only two controls', (
    tester,
  ) async {
    const portrait = Size(320, 568);
    useSize(tester, portrait);
    final motion = ManualTrayMotion();
    addTearDown(motion.close);
    final results = <int>[];
    await tester.pumpWidget(
      host(
        DiceTrayPage(
          solid: true,
          seed: 7,
          motion: motion,
          requestMotionAccess: () async => true,
          onSettled: results.add,
        ),
        reduced: true,
        fullscreen: true,
      ),
    );

    final stage = find.byType(DiceSceneLayers);
    expect(tester.getSize(stage).width, portrait.width);
    expect(tester.getSize(stage).height, greaterThan(portrait.height * .8));
    expect(find.text('Throw'), findsNothing);
    expect(find.text('Configure'), findsOneWidget);
    expect(find.text('Add a die'), findsOneWidget);
    expect(find.text('Motion sensors'), findsNothing);

    await tester.tap(stage);
    await tester.pumpAndSettle();
    expect(results, hasLength(1));
    final before = tester.widget<DiceSceneLayers>(stage).session.values;

    tester.view.physicalSize = const Size(568, 320);
    await tester.pumpAndSettle();
    expect(tester.getSize(stage).width, 568);
    expect(tester.widget<DiceSceneLayers>(stage).session.values, before);

    await tester.tap(find.text('Configure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Motion sensors'));
    await tester.pumpAndSettle();
    motion.throwWith(1);
    await tester.pumpAndSettle();
    expect(results, hasLength(2));
    expect(tester.takeException(), isNull);
  });

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
