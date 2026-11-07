import 'dart:convert';

import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';

abstract final class SheetExport {
  static String text(
    CharacterSheet sheet,
    Map<String, String> labels,
    List<String> steps,
  ) {
    final lines = <String>[];
    for (var step = 1; step <= SheetSpec.stepCount; step++) {
      final rows = [
        for (final f in SheetSpec.ofStep(step))
          if (sheet.of(f.id).isNotEmpty)
            '- ${labels[f.id] ?? f.id} : ${sheet.of(f.id).join(', ')}',
      ];
      if (rows.isEmpty) continue;
      if (lines.isNotEmpty) lines.add('');
      lines
        ..add('$step. ${steps[step - 1]}')
        ..addAll(rows);
    }
    return lines.join('\n');
  }

  static String jsonText(CharacterSheet sheet) =>
      const JsonEncoder.withIndent('  ').convert(sheet.toJson());
}
