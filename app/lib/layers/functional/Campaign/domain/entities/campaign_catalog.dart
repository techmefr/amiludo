const campaignUniverse = 'Ombrelune';

enum MissionAction { dice, life, sheet, generator, hourglass }

class Mission {
  const Mission({
    required this.id,
    required this.action,
    required this.minutes,
    this.hasChoice = false,
  });

  final String id;
  final MissionAction action;
  final int minutes;
  final bool hasChoice;
}

const campaignMissions = [
  Mission(id: 'first-roll', action: MissionAction.dice, minutes: 3),
  Mission(id: 'life-points', action: MissionAction.life, minutes: 3),
  Mission(id: 'hero-sheet', action: MissionAction.sheet, minutes: 5),
  Mission(id: 'first-fight', action: MissionAction.dice, minutes: 4),
  Mission(
    id: 'crossroads',
    action: MissionAction.generator,
    minutes: 4,
    hasChoice: true,
  ),
  Mission(id: 'final-scene', action: MissionAction.hourglass, minutes: 3),
];
