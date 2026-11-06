import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/data/accelerometer_turn_sensor.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_feed.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_shake_source.dart';
import 'package:amiludo/layers/technical/Sensors/accelerometer_turns.dart';
import 'package:amiludo/layers/technical/Sensors/motion_detectors.dart';
import 'package:amiludo/layers/technical/Sensors/sensor_sensitivity.dart';

class FakeFeed implements AccelerometerFeed {
  final controller = StreamController<AccelSample>.broadcast();
  @override
  Stream<AccelSample> get samples => controller.stream;
}

const rest = AccelSample(0, 0, 9.8);
const jolt = AccelSample(25, 0, 9.8);
final start = DateTime(2026, 1, 1);

DateTime at(int ms) => start.add(Duration(milliseconds: ms));

void main() {
  group('sensitivity', () {
    test('defaults to medium and parses names', () {
      expect(SensorSensitivity.parse(null), SensorSensitivity.medium);
      expect(SensorSensitivity.parse('high'), SensorSensitivity.high);
      expect(SensorSensitivity.parse('nonsense'), SensorSensitivity.medium);
      expect(const Appearance().sensors, 'medium');
    });

    test('is stored in appearance and validated', () {
      final json = const Appearance(sensors: 'low').toJson();
      expect(Appearance.fromJson(json).sensors, 'low');
      expect(
        () => Appearance.fromJson({...json, 'sensors': 'loud'}),
        throwsFormatException,
      );
      expect(
        Appearance.fromJson({...json}..remove('sensors')).sensors,
        'medium',
      );
    });

    test('higher sensitivity needs a smaller jolt', () {
      expect(
        SensorSensitivity.high.shakeThreshold,
        lessThan(SensorSensitivity.low.shakeThreshold),
      );
    });
  });

  group('shake detector', () {
    test('rest never shakes', () {
      final detector = ShakeDetector(threshold: 11);
      for (var i = 0; i < 20; i++) {
        expect(detector.add(rest, at(i * 20)), isFalse);
      }
    });

    test('two jolts in the window shake once then cool down', () {
      final detector = ShakeDetector(threshold: 11);
      expect(detector.add(jolt, at(0)), isFalse);
      expect(detector.add(jolt, at(200)), isTrue);
      expect(detector.add(jolt, at(300)), isFalse);
      expect(detector.add(jolt, at(400)), isFalse);
    });

    test('jolts too far apart do not count', () {
      final detector = ShakeDetector(threshold: 11);
      expect(detector.add(jolt, at(0)), isFalse);
      expect(detector.add(jolt, at(2000)), isFalse);
    });
  });

  group('turn detector', () {
    test('flipping upside down emits once', () {
      final detector = TurnDetector();
      expect(detector.add(const AccelSample(0, 9.8, 0), at(0)), isFalse);
      expect(detector.add(const AccelSample(0, 0, 0), at(100)), isFalse);
      expect(detector.add(const AccelSample(0, -9.8, 0), at(200)), isTrue);
      expect(detector.add(const AccelSample(0, 9.8, 0), at(300)), isFalse);
    });

    test('face down flip counts too', () {
      final detector = TurnDetector();
      expect(detector.add(rest, at(0)), isFalse);
      expect(detector.add(const AccelSample(0, 0, -9.8), at(500)), isTrue);
    });
  });

  group('sources', () {
    test('shake source emits for shakes only', () async {
      final feed = FakeFeed();
      var now = 0;
      final source = AccelerometerShakeSource(
        feed,
        SensorSensitivity.medium,
        clock: () => at(now),
      );
      var count = 0;
      final sub = source.shakes.listen((_) => count++);
      for (final ms in [0, 100]) {
        now = ms;
        feed.controller.add(jolt);
        await Future<void>.delayed(Duration.zero);
      }
      feed.controller.add(rest);
      await Future<void>.delayed(Duration.zero);
      expect(count, 1);
      await sub.cancel();
    });

    test('off emits nothing and never reads the sensor', () async {
      final feed = FakeFeed();
      final source = AccelerometerShakeSource(feed, SensorSensitivity.off);
      expect(await source.shakes.isEmpty, isTrue);
      expect(feed.controller.hasListener, isFalse);
    });

    test('turn sensor wraps the accelerometer turns', () async {
      final feed = FakeFeed();
      var now = 0;
      final sensor = AccelerometerTurnSensor(
        AccelerometerTurns(
          feed,
          SensorSensitivity.medium,
          clock: () => at(now),
        ),
      );
      var count = 0;
      final sub = sensor.turns.listen((_) => count++);
      feed.controller.add(const AccelSample(0, 9.8, 0));
      await Future<void>.delayed(Duration.zero);
      now = 500;
      feed.controller.add(const AccelSample(0, -9.8, 0));
      await Future<void>.delayed(Duration.zero);
      expect(count, 1);
      await sub.cancel();
    });

    test('no feed is silent', () async {
      expect(await const NoAccelerometerFeed().samples.isEmpty, isTrue);
    });
  });
}
