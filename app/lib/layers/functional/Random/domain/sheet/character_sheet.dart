import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';

class CharacterSheet {
  const CharacterSheet({
    required this.universe,
    this.culture,
    this.values = const {},
    this.locked = const {},
  });

  factory CharacterSheet.fromJson(Map<String, dynamic> j) {
    final raw = Map<String, dynamic>.from(j['values'] as Map? ?? const {});
    final values = <String, List<String>>{};
    for (final e in raw.entries) {
      final field = SheetSpec.find(e.key);
      final list = [for (final v in e.value as List) (v as String).trim()];
      if (field == null ||
          list.length > field.max ||
          list.any((v) => v.isEmpty || v.length > SheetSpec.maxLength)) {
        throw const FormatException('Fiche invalide');
      }
      values[e.key] = list;
    }
    final locked = {
      for (final id in j['locked'] as List? ?? const []) id as String,
    };
    if (locked.any((id) => SheetSpec.find(id) == null)) {
      throw const FormatException('Fiche invalide');
    }
    return CharacterSheet(
      universe: j['universe'] as String,
      culture: j['culture'] as String?,
      values: values,
      locked: locked,
    );
  }

  final String universe;
  final String? culture;
  final Map<String, List<String>> values;
  final Set<String> locked;

  List<String> of(String id) => values[id] ?? const [];

  String first(String id) => of(id).firstOrNull ?? '';

  bool isLocked(String id) => locked.contains(id);

  bool get isEmpty => values.values.every((v) => v.isEmpty);

  CharacterSheet withValue(String id, List<String> value, {bool lock = false}) {
    SheetSpec.field(id);
    return CharacterSheet(
      universe: universe,
      culture: culture,
      values: {...values, id: value},
      locked: lock ? {...locked, id} : locked,
    );
  }

  CharacterSheet withCulture(String? id) => CharacterSheet(
    universe: universe,
    culture: id,
    values: values,
    locked: locked,
  );

  CharacterSheet withLock(String id, bool lock) => CharacterSheet(
    universe: universe,
    culture: culture,
    values: values,
    locked: lock ? {...locked, id} : ({...locked}..remove(id)),
  );

  bool fieldComplete(SheetField f) {
    final n = of(f.id).length;
    return n >= f.min && n <= f.max;
  }

  bool stepComplete(int step) => SheetSpec.ofStep(step).every(fieldComplete);

  int get completedSteps => [
    for (var s = 1; s <= SheetSpec.stepCount; s++)
      if (stepComplete(s)) s,
  ].length;

  Map<String, Object?> toJson() => {
    'universe': universe,
    if (culture != null) 'culture': culture,
    'values': {
      for (final e in values.entries)
        if (e.value.isNotEmpty) e.key: e.value,
    },
    if (locked.isNotEmpty) 'locked': locked.toList()..sort(),
  };
}
