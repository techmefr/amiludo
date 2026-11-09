import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/l10n/app_localizations.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/hourglass.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_view.dart';

class FakeSensor implements TurnSensor {
  final controller = StreamController<void>.broadcast();
  @override
  Stream<void> get turns => controller.stream;
}

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  group('flow', () {
    test('sand falls only while running and finishes', () {
      final flow = HourglassState(const HourglassSettings(seconds: 10));
      flow.tick(const Duration(seconds: 3));
      expect(flow.fallen, Duration.zero);
      flow.start();
      flow.tick(const Duration(seconds: 4));
      expect(flow.upperFill, closeTo(0.6, 1e-9));
      expect(flow.lowerFill, closeTo(0.4, 1e-9));
      flow.tick(const Duration(seconds: 30));
      expect(flow.phase, HourglassPhase.finished);
      expect(flow.running, isFalse);
    });

    test('turning keeps the elapsed time and swaps the chambers', () {
      final flow = HourglassState(const HourglassSettings(seconds: 10))
        ..start()
        ..tick(const Duration(seconds: 4));
      flow.turn();
      expect(flow.turns, 1);
      expect(flow.upperFill, closeTo(0.4, 1e-9));
      expect(flow.remaining, const Duration(seconds: 4));
      flow.turn();
      expect(flow.remaining, const Duration(seconds: 6));
    });

    test('turning a finished glass starts it over', () {
      final flow = HourglassState(const HourglassSettings(seconds: 5))
        ..start()
        ..tick(const Duration(seconds: 5));
      flow.turn();
      expect(flow.phase, HourglassPhase.running);
      expect(flow.remaining, const Duration(seconds: 5));
    });

    test('reset empties the lower chamber', () {
      final flow = HourglassState(const HourglassSettings())
        ..start()
        ..tick(const Duration(seconds: 9))
        ..reset();
      expect(flow.phase, HourglassPhase.ready);
    });

    test('settings round trip through a brick and clamp seconds', () {
      const settings = HourglassSettings(seconds: 45, color: 0xFF112233);
      final brick = Brick(
        id: 'h',
        type: 'hourglass',
        settings: settings.toJson(),
      );
      final back = HourglassSettings.fromJson(
        Brick.fromJson(brick.toJson()).settings,
      );
      expect(back.seconds, 45);
      expect(back.color, 0xFF112233);
      expect(HourglassSettings.fromJson({'seconds': 0}).seconds, 1);
      expect(HourglassSettings.fromJson(const {}).seconds, 60);
    });

    test('the default sensor never reports a turn', () async {
      expect(await const NoTurnSensor().turns.isEmpty, isTrue);
    });
  });

  for (final size in const [Size(390, 844), Size(1280, 720)]) {
    group('view at $size', () {
      void setSize(WidgetTester tester) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
      }

      testWidgets('counts down, turns with the button, no overflow', (
        tester,
      ) async {
        setSize(tester);
        await tester.pumpWidget(
          host(const HourglassView(settings: HourglassSettings(seconds: 10))),
        );
        expect(find.text('00:10'), findsOneWidget);
        await tester.tap(find.text('Start'));
        await tester.pump(const Duration(seconds: 4));
        expect(find.text('00:06'), findsOneWidget);
        await tester.tap(find.text('Turn'));
        await tester.pump();
        expect(find.text('00:04'), findsOneWidget);
        await tester.tap(find.text('Pause'));
        await tester.pump();
        expect(find.text('Start'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('a sensor event turns the glass', (tester) async {
        setSize(tester);
        final sensor = FakeSensor();
        var turned = 0;
        await tester.pumpWidget(
          host(
            HourglassView(
              settings: const HourglassSettings(seconds: 10),
              sensor: sensor,
              onTurned: () => turned++,
            ),
          ),
        );
        await tester.tap(find.text('Start'));
        await tester.pump(const Duration(seconds: 3));
        sensor.controller.add(null);
        await tester.pump();
        expect(turned, 1);
        expect(find.text('00:03'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('granted motion access enables a physical turn', (
        tester,
      ) async {
        setSize(tester);
        final sensor = FakeSensor();
        addTearDown(sensor.controller.close);
        await tester.pumpWidget(
          host(
            HourglassTool(
              sensor: sensor,
              requestMotionAccess: () async => true,
            ),
          ),
        );
        expect(sensor.controller.hasListener, isFalse);
        await tester.tap(find.text('Enable motion'));
        await tester.pump();
        expect(sensor.controller.hasListener, isTrue);
        sensor.controller.add(null);
        await tester.pump();
        expect(find.text('Pause'), findsOneWidget);
        expect(find.text('01:00'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });

      testWidgets('reduced motion ticks once a second and finishes', (
        tester,
      ) async {
        setSize(tester);
        await tester.pumpWidget(
          host(
            const HourglassView(settings: HourglassSettings(seconds: 3)),
            reduced: true,
          ),
        );
        await tester.tap(find.text('Start'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('00:03'), findsOneWidget);
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('Time is up'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the tool changes the duration', (tester) async {
        setSize(tester);
        await tester.pumpWidget(host(const HourglassTool()));
        expect(find.text('01:00'), findsOneWidget);
        await tester.tap(find.text('30 s'));
        await tester.pump();
        expect(find.text('00:30'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
