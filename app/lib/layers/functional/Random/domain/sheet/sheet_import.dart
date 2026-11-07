import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_rules.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_generator.dart';

const _cardFields = {
  'nom': 'name',
  'surnom': 'nickname',
  'age': 'age',
  'naissance': 'birthDate',
  'genre': 'gender',
  'origine': 'origin',
  'langue': 'languages',
  'metier': 'job',
  'statut': 'status',
  'groupe': 'group',
  'peau': 'skin',
  'yeux': 'eyes',
  'cheveux': 'hair',
  'silhouette': 'build',
  'taille': 'height',
  'style': 'style',
  'signe': 'marks',
  'qualite': 'qualities',
  'defaut': 'flaws',
  'aime': 'likes',
  'deteste': 'dislikes',
  'talent': 'talents',
  'habitude': 'habits',
  'motivation': 'motivation',
  'but': 'goal',
  'famille': 'family',
  'enfance': 'childhood',
  'experience': 'experiences',
  'evolution': 'evolution',
  'situation': 'situation',
  'action': 'aims',
  'quete': 'aims',
};

abstract final class SheetImport {
  static CharacterSheet fromKept(
    SheetGenerator generator,
    String universe,
    List<KeptCard> kept,
  ) {
    final tables = generator.tables;
    final collected = <String, List<String>>{};
    for (final k in kept) {
      final id = _cardFields[k.card.type];
      if (id != null) collected.putIfAbsent(id, () => []).add(k.card.name);
    }
    var sheet = generator.blank(universe);
    final cultures = tables.universe(universe);
    for (final e in collected.entries) {
      final max = _limit(e.key);
      if (e.key == 'age' && int.tryParse(e.value.first) == null) continue;
      if (e.key == 'birthDate' && !_isDate(e.value.first)) continue;
      sheet = sheet.withValue(e.key, e.value.take(max).toList(), lock: true);
      if (e.key == 'origin') {
        sheet = sheet.withCulture(cultures.cultureNamed(e.value.first)?.id);
      }
    }
    sheet = generator.generateAll(sheet);
    for (final f in SheetSpec.fields) {
      sheet = generator.topUp(sheet, f.id);
    }
    return sheet;
  }

  static bool _isDate(String text) =>
      RegExp(r'^\d{1,2}/\d{1,2}/\d+$').hasMatch(text);

  static int _limit(String id) => switch (id) {
    'languages' || 'experiences' || 'aims' || 'likes' || 'dislikes' => 3,
    'marks' => 3,
    'qualities' || 'flaws' => 5,
    'talents' || 'habits' => 2,
    _ => 1,
  };
}
