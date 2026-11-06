import 'dart:convert';

import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_data.dart';
import 'package:amiludo/layers/functional/Random/domain/chronicles/chronicles_sheet.dart';

abstract final class ChroniclesExport {
  static String text(ChroniclesSheet sheet, ChroniclesData data) {
    final lines = <String>[
      sheet.name,
      '${sheet.epithet} · ${sheet.rarity.name} · ${sheet.universe.name}',
      '',
      [for (final s in data.stats) '${s.name} ${sheet.stats[s.id]}'].join(' · '),
    ];
    for (final section in sheet.sections) {
      lines
        ..add('')
        ..add(section.step.name);
      for (final k in section.fields) {
        lines.add('- ${sheet.labels[k.card.id]} : ${k.card.name}');
      }
    }
    return lines.join('\n');
  }

  static Map<String, Object?> json(ChroniclesSheet sheet) => {
    'universe': sheet.universe.id,
    'name': sheet.name,
    'epithet': sheet.epithet,
    'rarity': sheet.rarity.id,
    'stats': sheet.stats,
    'cards': [
      for (final k in sheet.kept)
        {
          'id': k.card.id,
          'type': k.card.type,
          'name': k.card.name,
          'rarity': k.card.rarity,
          'destiny': k.destiny,
        },
    ],
  };

  static String jsonText(ChroniclesSheet sheet) =>
      const JsonEncoder.withIndent('  ').convert(json(sheet));
}
