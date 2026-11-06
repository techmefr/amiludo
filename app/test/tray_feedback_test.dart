import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Physics/tray_body.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';
import 'package:amiludo/layers/technical/Sound/tray_sound_bank.dart';
import 'package:amiludo/layers/technical/Sound/wav_synth.dart';

class FakeFeed implements AccelerometerFeed {
  final controller = StreamController<AccelSample>.broadcast();
  @override
  Stream<AccelSample> get samples => controller.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );

  group('synthesized sound', () {
    test('writes a valid mono 16-bit wav', () {
      final wav = clatter(frequency: 800, decay: 80, seconds: 0.1, seed: 1);
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
      expect(wav.length, 44 + (sampleRate * 0.1).round() * 2);
    });

    test('is deterministic and depends on the surface', () {
      final wood = TraySoundBank(SurfaceMaterial.wood).impact(700, 1);
      expect(wood, TraySoundBank(SurfaceMaterial.wood).impact(700, 1));
      expect(wood, isNot(TraySoundBank(SurfaceMaterial.glass).impact(700, 1)));
      expect(TraySoundBank.levelOf(100), 0);
      expect(TraySoundBank.levelOf(400), 1);
      expect(TraySoundBank.levelOf(900), 2);
    });
  });

  group('tray feedback', () {
    test('impact volume grows with the impact speed', () {
      final out = RecordingSoundOutput();
      var ms = 0;
      final feedback = TrayFeedback(
        output: out,
        sound: true,
        clock: () => DateTime.fromMillisecondsSinceEpoch(ms),
      );
      feedback.impact(const TrayImpact(ImpactKind.floor, 200));
      ms = 100;
      feedback.impact(const TrayImpact(ImpactKind.floor, 800));
      expect(out.played.length, 2);
      expect(out.played[1].$2, greaterThan(out.played[0].$2));
    });

    test('sound off stays silent and impacts are throttled', () {
      final off = RecordingSoundOutput();
      TrayFeedback(output: off)
        ..impact(const TrayImpact(ImpactKind.wall, 800))
        ..thrown(1)
        ..settled();
      expect(off.played, isEmpty);
      final on = RecordingSoundOutput();
      TrayFeedback(output: on, sound: true, clock: () => DateTime(2026))
        ..impact(const TrayImpact(ImpactKind.wall, 800))
        ..impact(const TrayImpact(ImpactKind.wall, 800));
      expect(on.played.length, 1);
    });

    test('whoosh on throw and tick on settle', () {
      final out = RecordingSoundOutput();
      TrayFeedback(output: out, sound: true)
        ..thrown(1)
        ..settled();
      expect(out.played.length, 2);
    });

    test('haptics are light on impact and medium on settle', () async {
      TrayFeedback(haptics: true)
        ..impact(const TrayImpact(ImpactKind.die, 500))
        ..settled();
      await Future<void>.delayed(Duration.zero);
      expect(calls.map((c) => c.arguments), [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
      ]);
      calls.clear();
      TrayFeedback()
        ..impact(const TrayImpact(ImpactKind.die, 500))
        ..settled();
      await Future<void>.delayed(Duration.zero);
      expect(calls, isEmpty);
    });
  });

  group('phone motion', () {
    test('tilt follows the gravity vector', () {
      expect(tiltOf(const AccelSample(0, 0, 9.8)).x, 0);
      expect(tiltOf(const AccelSample(-9.8, 0, 0)).x, closeTo(1, 0.01));
      expect(tiltOf(const AccelSample(0, 9.8, 0)).y, closeTo(1, 0.01));
    });

    test('a harder shake gives a stronger throw', () {
      expect(
        strengthOf(const AccelSample(40, 0, 9.8), 11),
        greaterThan(strengthOf(const AccelSample(22, 0, 9.8), 11)),
      );
    });

    test('a flick along the top edge is recognised', () {
      expect(isFlick(const AccelSample(0, 30, 2), 11), isTrue);
      expect(isFlick(const AccelSample(0, 0, 9.8), 11), isFalse);
    });

    test('the stream throws on shakes and reports tilt', () async {
      final feed = FakeFeed();
      var now = 0;
      final motion = AccelerometerTrayMotion(
        feed,
        SensorSensitivity.medium,
        clock: () => DateTime(2026).add(Duration(milliseconds: now)),
      );
      final strengths = <double>[];
      final tilts = <Tilt>[];
      final a = motion.throws.listen(strengths.add);
      final b = motion.tilts.listen(tilts.add);
      for (final ms in [0, 100]) {
        now = ms;
        feed.controller.add(const AccelSample(25, 0, 9.8));
        await Future<void>.delayed(Duration.zero);
      }
      expect(strengths.length, 1);
      expect(tilts.length, 2);
      await a.cancel();
      await b.cancel();
    });

    test('off emits nothing', () async {
      final motion = AccelerometerTrayMotion(FakeFeed(), SensorSensitivity.off);
      expect(await motion.throws.isEmpty, isTrue);
      expect(await motion.tilts.isEmpty, isTrue);
    });
  });
}
