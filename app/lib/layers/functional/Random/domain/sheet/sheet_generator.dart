import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_dates.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';

class SheetGenerator {
  const SheetGenerator(this.tables, this.random);
  final SheetTables tables;
  final RandomTools random;

  CharacterSheet blank(String universe) {
    tables.universe(universe);
    return CharacterSheet(universe: universe);
  }

  CharacterSheet generateAll(CharacterSheet sheet) {
    var next = sheet;
    for (var step = 1; step <= SheetSpec.stepCount; step++) {
      next = generateStep(next, step);
    }
    return next;
  }

  CharacterSheet generateStep(CharacterSheet sheet, int step) {
    final fields = SheetSpec.ofStep(step);
    final ordered = [
      ...fields.where((f) => f.id == 'origin'),
      ...fields.where((f) => f.id != 'origin'),
    ];
    var next = _anchored(sheet);
    for (final f in ordered) {
      if (!next.isLocked(f.id)) next = _fill(next, f, force: false);
    }
    return next;
  }

  CharacterSheet rerollField(CharacterSheet sheet, String id) {
    if (sheet.isLocked(id)) return sheet;
    var next = _fill(_anchored(sheet), SheetSpec.field(id), force: true);
    for (final dep in SheetSpec.dependents[id] ?? const <String>[]) {
      if (!next.isLocked(dep)) {
        next = _fill(next, SheetSpec.field(dep), force: true);
      }
    }
    return next;
  }

  CharacterSheet edit(CharacterSheet sheet, String id, List<String> value) {
    final field = SheetSpec.field(id);
    final clean = [
      for (final v in value)
        if (v.trim().isNotEmpty) v.trim(),
    ];
    if (clean.length > field.max ||
        clean.length < field.min ||
        clean.any((v) => v.length > SheetSpec.maxLength)) {
      throw const FormatException('Valeur invalide');
    }
    var next = sheet.withValue(id, clean, lock: true);
    final universe = tables.universe(sheet.universe);
    if (id == 'origin') {
      next = next.withCulture(universe.cultureNamed(clean.first)?.id);
    } else if (id == 'age' && !next.isLocked('birthDate')) {
      next = _fill(next, SheetSpec.field('birthDate'), force: true);
    } else if (id == 'birthDate') {
      final birth = SheetDate.parse(clean.first);
      if (birth != null && !next.isLocked('age')) {
        next = next.withValue('age', [
          '${SheetDates.ageAt(universe.era, birth)}',
        ]);
      }
    }
    return next;
  }

  CharacterSheet _fill(CharacterSheet s, SheetField f, {required bool force}) {
    final universe = tables.universe(s.universe);
    switch (f.id) {
      case 'origin':
        final c = random.pick(universe.cultures);
        return s.withCulture(c.id).withValue('origin', [c.name]);
      case 'name':
        final c = _culture(s);
        return s.withValue('name', [
          '${random.pick(c.firstNames)} ${random.pick(c.lastNames)}',
        ]);
      case 'age':
        final birth = s.isLocked('birthDate')
            ? SheetDate.parse(s.first('birthDate'))
            : null;
        final age = birth == null
            ? random.integer(SheetDates.minAge, SheetDates.maxAge)
            : SheetDates.ageAt(universe.era, birth);
        final next = s.withValue('age', ['$age']);
        return next.isLocked('birthDate')
            ? next
            : _fill(next, SheetSpec.field('birthDate'), force: force);
      case 'birthDate':
        if (s.of('age').isEmpty) {
          return _fill(s, SheetSpec.field('age'), force: force);
        }
        final age = int.tryParse(s.first('age'));
        if (age == null) return s;
        return s.withValue('birthDate', [
          '${SheetDates.birthFor(universe.era, age, random)}',
        ]);
      case 'birthPlace':
        return s.withValue('birthPlace', [random.pick(_culture(s).places)]);
      case 'languages':
        return s.withValue('languages', _languages(s));
    }
    return s.withValue(f.id, _draw(s, f, force));
  }

  SheetCulture _culture(CharacterSheet s) {
    final universe = tables.universe(s.universe);
    return universe.culture(s.culture) ?? random.pick(universe.cultures);
  }

  List<String> _languages(CharacterSheet s) {
    final own = _culture(s).languages;
    final extra = {for (final o in tables.pool(s.universe, 'languages')) o.text}
        .where((t) => !own.contains(t))
        .toList();
    final pool = random.shuffled([...own.skip(1), ...extra]);
    return [own.first, ...pool.take(random.integer(0, 2))];
  }

  Set<String> _excluded(CharacterSheet s, String id) => switch (id) {
    'qualities' => {...s.of('flaws'), ...tables.oppositesOf(s.of('flaws'))},
    'flaws' => {...s.of('qualities'), ...tables.oppositesOf(s.of('qualities'))},
    'likes' => s.of('dislikes').toSet(),
    'dislikes' => s.of('likes').toSet(),
    _ => const {},
  };

  List<String> _pool(CharacterSheet s, SheetField f) {
    final banned = _excluded(s, f.id);
    final texts = {for (final o in tables.pool(s.universe, f.id)) o.text}
        .toList();
    final allowed = texts.where((t) => !banned.contains(t)).toList();
    return allowed.length >= f.min ? allowed : texts;
  }

  List<String> _draw(CharacterSheet s, SheetField f, bool force) {
    final low = f.optional && force ? 1 : f.min;
    final count = f.min == f.max ? f.max : random.integer(low, f.max);
    return random.shuffled(_pool(s, f)).take(count).toList();
  }

  CharacterSheet topUp(CharacterSheet s, String id) {
    final f = SheetSpec.field(id), have = s.of(id);
    if (have.length >= f.min) return s;
    final more = random.shuffled([
      for (final t in _pool(s, f))
        if (!have.contains(t)) t,
    ]);
    return s.withValue(id, [...have, ...more.take(f.min - have.length)]);
  }

  CharacterSheet _anchored(CharacterSheet s) => s.culture != null
      ? s
      : s.withCulture(random.pick(tables.universe(s.universe).cultures).id);
}
