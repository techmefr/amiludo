import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';

void main() {
  test('a value stops at its bounds', () {
    final life = CounterState(lifePreset);
    life.change(-80);
    expect(life.value, 0);
    life.change(500);
    expect(life.value, 99);
  });

  test('reaching the minimum triggers the configured outcome', () {
    final life = CounterState(lifePreset);
    expect(life.triggersOutcome, isFalse);
    life.change(-50);
    expect(life.triggersOutcome, isTrue);
    final plain = CounterState(const CounterSettings(minimum: 0, start: 1));
    plain.decrease();
    expect(plain.triggersOutcome, isFalse);
  });

  test('every change can be undone, and clamped no-ops are not recorded', () {
    final points = CounterState(pointsPreset);
    points.increase();
    points.change(5);
    expect(points.value, 6);
    points.undo();
    expect(points.value, 1);
    points.undo();
    expect(points.value, 0);
    expect(points.canUndo, isFalse);
    final chips = CounterState(const CounterSettings(minimum: 0));
    chips.decrease();
    expect(chips.history, isEmpty);
  });

  test('step is configurable and reset goes back to the start value', () {
    final chips = CounterState(chipsPreset);
    chips.increase();
    expect(chips.value, 1050);
    chips.reset();
    expect(chips.value, 1000);
    chips.undo();
    expect(chips.value, 1050);
  });

  test('settings round trip and unknown enum values fall back', () {
    final back = CounterSettings.fromJson(lifePreset.toJson());
    expect(back.display, CounterDisplay.bar);
    expect(back.outcome, CounterOutcome.eliminated);
    expect(back.maximum, 99);
    final odd = CounterSettings.fromJson({'display': 'unknown'});
    expect(odd.display, CounterDisplay.number);
  });
}
