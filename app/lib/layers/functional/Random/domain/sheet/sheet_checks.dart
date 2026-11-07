import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_dates.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';

enum SheetProblemKind { ageBirth, qualityFlaw, culture, count }

class SheetProblem {
  const SheetProblem(this.kind, this.fields);
  final SheetProblemKind kind;
  final List<String> fields;
}

abstract final class SheetChecks {
  static List<SheetProblem> problems(CharacterSheet sheet, SheetTables tables) {
    final universe = tables.universe(sheet.universe);
    final found = <SheetProblem>[];
    final birth = SheetDate.parse(sheet.first('birthDate'));
    final age = int.tryParse(sheet.first('age'));
    if (birth != null &&
        age != null &&
        SheetDates.ageAt(universe.era, birth) != age) {
      found.add(const SheetProblem(SheetProblemKind.ageBirth, ['age', 'birthDate']));
    }
    final flaws = sheet.of('flaws');
    final qualities = sheet.of('qualities');
    final clash = tables.oppositesOf(qualities);
    if (flaws.any((f) => clash.contains(f) || qualities.contains(f))) {
      found.add(const SheetProblem(SheetProblemKind.qualityFlaw, ['qualities', 'flaws']));
    }
    final culture = universe.culture(sheet.culture);
    if (culture != null) {
      final spoken = sheet.of('languages');
      final place = sheet.first('birthPlace');
      final nameOk = sheet.first('name').isEmpty ||
          culture.firstNames.any(sheet.first('name').startsWith);
      if ((spoken.isNotEmpty && !culture.languages.any(spoken.contains)) ||
          (place.isNotEmpty && !culture.places.contains(place)) ||
          !nameOk) {
        found.add(const SheetProblem(SheetProblemKind.culture, ['origin', 'name', 'languages']));
      }
    }
    for (final f in SheetSpec.fields) {
      if (sheet.of(f.id).isNotEmpty && !sheet.fieldComplete(f)) {
        found.add(SheetProblem(SheetProblemKind.count, [f.id]));
      }
    }
    return found;
  }
}
