import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

void main() {
  const settings = DiceTraySettings(
    dice: [DiceSpec(sides: 6), DiceSpec(sides: 20), DiceSpec(sides: 4)],
  );

  test('a seeded throw is reproducible and within each die range', () {
    final a = DiceTraySession(settings: settings).throwDice(SeededRandom(9));
    final b = DiceTraySession(settings: settings).throwDice(SeededRandom(9));
    expect(a.values, b.values);
    expect(a.values[0], inInclusiveRange(1, 6));
    expect(a.values[1], inInclusiveRange(1, 20));
    expect(a.values[2], inInclusiveRange(1, 4));
    expect(a.total, a.values.fold<int>(0, (s, v) => s + v));
  });

  test('a kept die keeps its value on the next throw', () {
    var session = DiceTraySession(
      settings: settings,
    ).throwDice(SeededRandom(1));
    final kept = session.values[1];
    session = session.toggleKeep(1);
    for (var seed = 2; seed < 12; seed++) {
      session = session.throwDice(SeededRandom(seed));
      expect(session.values[1], kept);
    }
    expect(session.toggleKeep(1).kept, isEmpty);
  });

  test('keeping before the first throw does nothing', () {
    expect(DiceTraySession(settings: settings).toggleKeep(0).kept, isEmpty);
  });

  test('history lists the latest throws first and stops at twenty', () {
    var session = DiceTraySession(settings: settings);
    for (var i = 0; i < 25; i++) {
      session = session.throwDice(SeededRandom(i + 1));
    }
    expect(session.history, hasLength(20));
    expect(session.history.first.values, session.values);
  });

  test('custom faces are labelled and left out of the total', () {
    final custom = DiceSpec.custom(['Sun', 'Moon', 'Star'], 0xFFD9573D);
    final session = DiceTraySession(
      settings: DiceTraySettings(dice: [custom, const DiceSpec(sides: 6)]),
    ).throwDice(SeededRandom(4));
    expect(custom.sides, 3);
    expect(custom.faceLabel(2), 'Moon');
    expect(session.total, session.values[1]);
  });

  test('settings survive a brick round trip', () {
    final custom = DiceSpec.custom(['A', 'B'], 0xFF3DA66B);
    final brick = DiceTraySettings(
      dice: [const DiceSpec(sides: 12), custom],
    ).toBrick('tray');
    expect(brick.type, diceTrayBrickType);
    final back = DiceTraySettings.fromJson(
      Brick.fromJson(brick.toJson()).settings,
    );
    expect(back.dice[0].sides, 12);
    expect(back.dice[1].faces, ['A', 'B']);
    expect(back.dice[1].color, 0xFF3DA66B);
  });

  test('broken settings fall back to two d6', () {
    final back = DiceTraySettings.fromJson({'dice': [{'sides': 1}]});
    expect(back.dice, hasLength(2));
  });
}
