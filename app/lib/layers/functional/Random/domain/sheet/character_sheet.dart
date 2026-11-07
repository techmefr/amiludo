import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';

const _keep = Object();

class CharacterSheet {
  const CharacterSheet({
    required this.universe,
    this.culture,
    this.edition,
    this.avatar,
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
      edition: j['edition'] as String?,
      avatar: j['avatar'] == null
          ? null
          : Map<String, Object?>.from(j['avatar'] as Map),
      values: values,
      locked: locked,
    );
  }

  final String universe;
  final String? culture, edition;
  final Map<String, Object?>? avatar;
  final Map<String, List<String>> values;
  final Set<String> locked;

  List<String> of(String id) => values[id] ?? const [];

  String first(String id) => of(id).firstOrNull ?? '';

  bool isLocked(String id) => locked.contains(id);

  bool get isEmpty => values.values.every((v) => v.isEmpty);

  CharacterSheet _copy({
    Object? culture = _keep,
    Object? edition = _keep,
    Object? avatar = _keep,
    Map<String, List<String>>? values,
    Set<String>? locked,
  }) => CharacterSheet(
    universe: universe,
    culture: identical(culture, _keep) ? this.culture : culture as String?,
    edition: identical(edition, _keep) ? this.edition : edition as String?,
    avatar: identical(avatar, _keep)
        ? this.avatar
        : avatar as Map<String, Object?>?,
    values: values ?? this.values,
    locked: locked ?? this.locked,
  );

  CharacterSheet withValue(String id, List<String> value, {bool lock = false}) {
    SheetSpec.field(id);
    return _copy(
      values: {...values, id: value},
      locked: lock ? {...locked, id} : locked,
    );
  }

  CharacterSheet withCulture(String? id) => _copy(culture: id);

  CharacterSheet withEdition(String? id) => _copy(edition: id);

  CharacterSheet withAvatar(Map<String, Object?>? json) => _copy(avatar: json);

  CharacterSheet withLock(String id, bool lock) =>
      _copy(locked: lock ? {...locked, id} : ({...locked}..remove(id)));

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
    if (edition != null) 'edition': edition,
    if (avatar != null) 'avatar': avatar,
    'values': {
      for (final e in values.entries)
        if (e.value.isNotEmpty) e.key: e.value,
    },
    if (locked.isNotEmpty) 'locked': locked.toList()..sort(),
  };
}
