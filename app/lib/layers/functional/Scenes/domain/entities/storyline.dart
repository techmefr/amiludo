import 'package:amiludo/layers/functional/Scenes/domain/entities/scene.dart';

class Storyline {
  const Storyline({this.scenes = const []});

  factory Storyline.fromJson(Map<String, dynamic> j) => Storyline(
    scenes: [
      for (final s in j['scenes'] as List? ?? const [])
        Scene.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
  );

  final List<Scene> scenes;

  bool get isEmpty => scenes.isEmpty;

  Scene? of(String id) => scenes.where((s) => s.id == id).firstOrNull;

  Storyline put(Scene next) {
    final known = scenes.any((s) => s.id == next.id);
    final valid = {for (final s in scenes) s.id, next.id}..remove(next.id);
    final cleaned = Scene(
      id: next.id,
      title: next.title,
      notes: next.notes,
      handout: next.handout,
      nextIds: [
        for (final id in next.nextIds)
          if (valid.contains(id)) id,
      ],
      creatureIds: next.creatureIds,
    );
    return Storyline(
      scenes: known
          ? [for (final s in scenes) s.id == next.id ? cleaned : s]
          : [...scenes, cleaned],
    );
  }

  Storyline remove(String id) => Storyline(
    scenes: [
      for (final s in scenes)
        if (s.id != id)
          Scene(
            id: s.id,
            title: s.title,
            notes: s.notes,
            handout: s.handout,
            nextIds: [
              for (final n in s.nextIds)
                if (n != id) n,
            ],
            creatureIds: s.creatureIds,
          ),
    ],
  );

  Storyline move(String id, int delta) {
    final from = scenes.indexWhere((s) => s.id == id);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= scenes.length) return this;
    final next = [...scenes];
    final scene = next.removeAt(from);
    next.insert(to, scene);
    return Storyline(scenes: next);
  }

  List<Scene> followers(Scene scene) => [
    for (final id in scene.nextIds)
      if (of(id) != null) of(id)!,
  ];

  Map<String, Object?> toJson() => {
    'scenes': [for (final s in scenes) s.toJson()],
  };
}
