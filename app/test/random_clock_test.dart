import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Timer/domain/entities/game_clock.dart';
import 'package:amiludo/layers/technical/Appearance/appearance.dart';

void main() {
  test(
    'shuffling and team creation neither lose nor duplicate participants',
    () {
      final random = RandomTools(random: Random(42));
      for (var size = 2; size <= 32; size++) {
        final source = List.generate(size, (i) => i);
        for (var count = 2; count <= size; count++) {
          final teams = random.teams(source, count);
          expect(teams.expand((t) => t).toSet(), source.toSet());
          expect(
            teams.map((t) => t.length).reduce(max) -
                teams.map((t) => t.length).reduce(min),
            lessThanOrEqualTo(1),
          );
        }
      }
    },
  );
  test('dice lock, limits and expressions hold', () {
    final random = RandomTools(random: Random(1));
    final rolls = random.dice(6, 4, locked: {1}, previous: [1, 5, 2, 3]);
    expect(rolls[1], 5);
    expect(rolls.every((v) => v >= 1 && v <= 6), isTrue);
    final expression = random.evaluate('2d6+3');
    expect(expression.total, inInclusiveRange(5, 15));
    expect(() => random.evaluate('eval(1)'), throwsFormatException);
    expect(() => random.dice(1, 5), throwsArgumentError);
  });
  test('weighted draws reject invalid inputs and exclude zero weights', () {
    final random = RandomTools(random: Random(1));
    for (var i = 0; i < 20; i++) {
      expect(random.weighted(['a', 'b'], [0, 1]), 'b');
    }
    expect(() => random.weighted(['a'], [0]), throwsArgumentError);
    expect(() => random.weighted(['a'], [-1]), throwsArgumentError);
  });
  test('clock freezes on pause, clamps expiry and applies increments', () {
    const clock = GameClock(
      remainingMs: 5000,
      durationMs: 5000,
      incrementMs: 2000,
    );
    final running = clock.start(10000);
    expect(running.remainingAt(12000), 3000);
    final paused = running.pause(12000);
    expect(paused.remainingAt(90000), 3000);
    expect(paused.start(20000).remainingAt(90000), 0);
    expect(running.increment(12000).remainingMs, 5000);
    expect(running.reset().remainingMs, 5000);
  });
  test('running clock can be restored from a persisted deadline', () {
    final restored = GameClock.fromJson(
      const GameClock(
        remainingMs: 10000,
        durationMs: 10000,
      ).start(10000).toJson(),
    );
    expect(restored.remainingAt(15000), 5000);
    expect(clockText(4999), '00:05');
  });
  test('old prototype styles import and invalid styles are refused', () {
    expect(
      Appearance.fromJson({
        'font': 'mono',
        'skin': 'cyber',
        'palette': 'acid',
        'shape': 'cut',
      }).font,
      'IBMPlexMono',
    );
    expect(
      () => Appearance.fromJson({'skin': 'unknown'}),
      throwsFormatException,
    );
  });
}
