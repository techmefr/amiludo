import 'dart:convert';

import 'package:amiludo/layers/functional/Bestiary/domain/entities/creature.dart';

const bestiaryExportFormat = 'amiludo-bestiary';

class Bestiary {
  const Bestiary({this.creatures = const []});

  factory Bestiary.fromJson(Map<String, dynamic> j) => Bestiary(
    creatures: [
      for (final c in j['creatures'] as List? ?? const [])
        Creature.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
  );

  final List<Creature> creatures;

  bool get isEmpty => creatures.isEmpty;

  Creature? of(String id) => creatures.where((c) => c.id == id).firstOrNull;

  List<String> get tags =>
      ({for (final c in creatures) ...c.tags}.toList()..sort());

  Bestiary put(Creature next) {
    final known = creatures.any((c) => c.id == next.id);
    return Bestiary(
      creatures: known
          ? [for (final c in creatures) c.id == next.id ? next : c]
          : [...creatures, next],
    );
  }

  Bestiary remove(String id) => Bestiary(
    creatures: [
      for (final c in creatures)
        if (c.id != id) c,
    ],
  );

  List<Creature> filter({
    String query = '',
    CreatureKind? kind,
    String? tag,
  }) {
    final found = [
      for (final c in creatures)
        if ((kind == null || c.kind == kind) &&
            (tag == null || c.tags.contains(tag)) &&
            c.matches(query))
          c,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return found;
  }

  String export() => const JsonEncoder.withIndent('  ').convert({
    'format': bestiaryExportFormat,
    'creatures': [for (final c in creatures) c.toJson()],
  });

  ({Bestiary merged, int count})? import(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return null;
    }
    final list = switch (decoded) {
      {'format': bestiaryExportFormat, 'creatures': final List items} => items,
      List items => items,
      _ => null,
    };
    if (list == null) return null;
    var merged = this;
    var count = 0;
    for (final item in list) {
      if (item is! Map) return null;
      final creature = Creature.fromJson(Map<String, dynamic>.from(item));
      if (creature.name.trim().isEmpty) continue;
      merged = merged.put(creature);
      count++;
    }
    return count == 0 ? null : (merged: merged, count: count);
  }

  Map<String, Object?> toJson() => {
    'creatures': [for (final c in creatures) c.toJson()],
  };
}
