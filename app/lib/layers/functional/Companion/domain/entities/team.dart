import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/hero.dart';

const teamBrickType = 'team';

class TeamSettings {
  const TeamSettings({this.name = '', this.heroes = const []});

  factory TeamSettings.fromJson(Map<String, dynamic> j) => TeamSettings(
    name: j['name'] as String? ?? '',
    heroes: [
      for (final h in j['heroes'] as List? ?? const [])
        HeroSettings.fromJson(Map<String, dynamic>.from(h as Map)),
    ],
  );

  final String name;
  final List<HeroSettings> heroes;

  Map<String, dynamic> toJson() => {
    'name': name,
    'heroes': heroes.map((h) => h.toJson()).toList(),
  };

  Brick toBrick(String id) =>
      Brick(id: id, type: teamBrickType, settings: toJson());
}

class TeamState {
  TeamState(this.settings)
    : heroes = [for (final h in settings.heroes) HeroState(h)];

  final TeamSettings settings;
  final List<HeroState> heroes;
  int _active = 0;

  int get activeIndex => heroes.isEmpty ? -1 : _active;

  HeroState? get active => heroes.isEmpty ? null : heroes[_active];

  void setActive(int index) {
    if (index < 0 || index >= heroes.length) return;
    _active = index;
  }

  void add(HeroSettings hero) {
    heroes.add(HeroState(hero));
    _active = heroes.length - 1;
  }

  void remove(int index) {
    if (index < 0 || index >= heroes.length) return;
    heroes.removeAt(index);
    if (_active >= heroes.length) {
      _active = heroes.isEmpty ? 0 : heroes.length - 1;
    }
  }

  void chargeAll([int events = 1]) {
    for (final hero in heroes) {
      hero.chargeAll(events);
    }
  }

  TeamSettings snapshot() => TeamSettings(
    name: settings.name,
    heroes: [for (final h in heroes) h.settings],
  );
}
