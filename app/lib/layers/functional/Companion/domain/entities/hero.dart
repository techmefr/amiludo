import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/power.dart';

const heroBrickType = 'hero';

const heroPalette = [0xFF3D7BD9, 0xFFD94A4A, 0xFF2F9E6B, 0xFFE0A526, 0xFF8A55C7];

class HeroSettings {
  const HeroSettings({
    this.name = '',
    this.color = 0xFF3D7BD9,
    this.counters = const [],
    this.powers = const [],
    this.avatar = const AvatarLook(),
  });

  factory HeroSettings.fromJson(Map<String, dynamic> j) => HeroSettings(
    name: j['name'] as String? ?? '',
    color: (j['color'] as num? ?? 0xFF3D7BD9).toInt(),
    counters: [
      for (final c in j['counters'] as List? ?? const [])
        CounterSettings.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
    powers: [
      for (final p in j['powers'] as List? ?? const [])
        PowerSettings.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    avatar: AvatarLook.fromJson(
      j['avatar'] == null
          ? null
          : Map<String, dynamic>.from(j['avatar'] as Map),
    ),
  );

  final String name;
  final int color;
  final List<CounterSettings> counters;
  final List<PowerSettings> powers;
  final AvatarLook avatar;

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color,
    'counters': counters.map((c) => c.toJson()).toList(),
    'powers': powers.map((p) => p.toJson()).toList(),
    if (!avatar.isEmpty) 'avatar': avatar.toJson(),
  };

  Brick toBrick(String id) =>
      Brick(id: id, type: heroBrickType, settings: toJson());
}

class HeroState {
  HeroState(HeroSettings initial)
    : name = initial.name,
      color = initial.color,
      counters = [for (final c in initial.counters) CounterState(c)],
      powers = [for (final p in initial.powers) PowerState(p)],
      avatar = initial.avatar;

  final String name;
  final int color;
  final List<CounterState> counters;
  final List<PowerState> powers;
  AvatarLook avatar;

  HeroSettings get settings => HeroSettings(
    name: name,
    color: color,
    counters: [for (final c in counters) c.settings],
    powers: [for (final p in powers) p.settings],
    avatar: avatar,
  );

  void addPower(PowerSettings power) => powers.add(PowerState(power));

  void chargeAll([int events = 1]) {
    for (final power in powers) {
      power.charge(events);
    }
  }

  void resetPowers() {
    for (final power in powers) {
      power.reset();
    }
  }
}
