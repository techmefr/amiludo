import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/hero.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/power.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/team.dart';

void main() {
  test('a power charges by its rule, becomes ready, is used and resets', () {
    final power = PowerState(
      const PowerSettings(name: 'a', chargePerEvent: 2, threshold: 5),
    );
    expect(power.status, PowerStatus.charging);
    expect(power.use(), isFalse);
    power.charge();
    expect(power.charges, 2);
    power.charge(2);
    expect(power.charges, 5);
    expect(power.status, PowerStatus.ready);
    expect(power.progress, 1);
    expect(power.use(), isTrue);
    expect(power.status, PowerStatus.used);
    power.charge();
    expect(power.charges, 0);
    expect(power.use(), isFalse);
    power.reset();
    expect(power.status, PowerStatus.charging);
  });

  test('a threshold below one still needs one charge', () {
    final power = PowerState(const PowerSettings(threshold: 0));
    expect(power.target, 1);
    power.charge();
    expect(power.status, PowerStatus.ready);
  });

  test('a hero keeps its counters and powers through json', () {
    const hero = HeroSettings(
      name: 'Ada',
      color: 0xFFD94A4A,
      counters: [pointsPreset],
      powers: [PowerSettings(name: 'p', chargePerEvent: 2, threshold: 4)],
    );
    final brick = Brick.fromJson(hero.toBrick('h1').toJson());
    expect(brick.type, heroBrickType);
    final back = HeroSettings.fromJson(brick.settings);
    expect(back.name, 'Ada');
    expect(back.counters.single.name, 'points');
    expect(back.powers.single.threshold, 4);
    final state = HeroState(back);
    state.chargeAll(2);
    expect(state.powers.single.status, PowerStatus.ready);
    state.resetPowers();
    expect(state.powers.single.charges, 0);
  });

  test('a team tracks one active hero and survives json', () {
    final team = TeamState(const TeamSettings(name: 'T'));
    expect(team.active, isNull);
    team.add(const HeroSettings(name: 'a'));
    team.add(const HeroSettings(name: 'b'));
    expect(team.active?.name, 'b');
    team.setActive(0);
    team.setActive(9);
    expect(team.active?.name, 'a');
    team.remove(0);
    expect(team.active?.name, 'b');
    team.active!.addPower(const PowerSettings(name: 'p'));
    team.chargeAll(3);
    final brick = team.snapshot().toBrick('t1');
    expect(brick.type, teamBrickType);
    final back = TeamSettings.fromJson(brick.settings);
    expect(back.heroes.single.powers.single.name, 'p');
  });
}
