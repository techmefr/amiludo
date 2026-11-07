class SheetField {
  const SheetField(this.id, this.step, {this.min = 1, this.max = 1});
  final String id;
  final int step;
  final int min, max;
  bool get isList => max > 1;
  bool get optional => min == 0;
}

abstract final class SheetSpec {
  static const stepCount = 5;

  static const fields = [
    SheetField('name', 1),
    SheetField('nickname', 1, min: 0),
    SheetField('age', 1),
    SheetField('birthDate', 1),
    SheetField('birthPlace', 1),
    SheetField('gender', 1),
    SheetField('origin', 1),
    SheetField('languages', 1, max: 3),
    SheetField('job', 1),
    SheetField('status', 1),
    SheetField('group', 1),
    SheetField('skin', 2),
    SheetField('eyes', 2),
    SheetField('hair', 2),
    SheetField('build', 2),
    SheetField('height', 2),
    SheetField('style', 2),
    SheetField('marks', 2, min: 0, max: 3),
    SheetField('qualities', 3, min: 5, max: 5),
    SheetField('flaws', 3, min: 5, max: 5),
    SheetField('likes', 3, max: 3),
    SheetField('dislikes', 3, max: 3),
    SheetField('talents', 3, max: 2),
    SheetField('habits', 3, max: 2),
    SheetField('motivation', 3),
    SheetField('goal', 3),
    SheetField('family', 4),
    SheetField('childhood', 4),
    SheetField('experiences', 4, max: 3),
    SheetField('evolution', 4),
    SheetField('situation', 5),
    SheetField('aims', 5, max: 3),
  ];

  static const dependents = {
    'origin': ['name', 'birthPlace', 'languages'],
  };

  static const maxLength = 200;

  static SheetField? find(String id) =>
      fields.where((f) => f.id == id).firstOrNull;

  static SheetField field(String id) =>
      find(id) ?? (throw ArgumentError('Champ inconnu : $id'));

  static List<SheetField> ofStep(int step) => [
    for (final f in fields)
      if (f.step == step) f,
  ];
}
