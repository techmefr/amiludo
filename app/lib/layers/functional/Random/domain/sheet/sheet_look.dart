import 'package:amiludo/layers/functional/Random/domain/sheet/character_sheet.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_tables.dart';

class SheetLook {
  const SheetLook({
    this.tints = const {},
    this.pieces = const [],
    this.hairless = false,
    this.colors = const {},
  });

  final Map<String, int> tints;
  final List<String> pieces;
  final bool hairless;
  final Map<String, String> colors;

  static const _tinted = {'skin': 'skin', 'eyes': 'eyes', 'hair': 'hair'};

  static int _spread(String text, int count) =>
      1 + text.codeUnits.fold(0, (a, b) => a + b) % count;

  static String? _piece(SheetOption option) => switch (option.kind) {
    'scar' => 'marks.marks-${_spread(option.text, 7)}',
    'scales' => 'marks.scales-marks-${_spread(option.text, 20)}',
    'mech-eyes' => 'eyes.eyes-mechanical-a-${_spread(option.text, 4)}',
    _ => null,
  };

  static SheetLook of(CharacterSheet sheet, SheetTables tables) {
    SheetOption? option(String field, String text) => tables
        .pool(sheet.universe, field)
        .where((o) => o.text == text)
        .firstOrNull;
    final tints = <String, int>{}, colors = <String, String>{};
    final pieces = <String>[];
    var hairless = false;
    for (final e in _tinted.entries) {
      final o = option(e.key, sheet.first(e.key));
      if (o?.palette != null) {
        tints[e.value] = o!.palette!;
        final hex = tables.colorOf(e.value, o.palette!);
        if (hex != null) colors[e.value] = hex;
      }
      if (e.key == 'hair' && o?.kind == 'bald') hairless = true;
    }
    final mech = option('eyes', sheet.first('eyes'));
    final eyePiece = mech == null ? null : _piece(mech);
    if (eyePiece != null) pieces.add(eyePiece);
    for (final mark in sheet.of('marks')) {
      final piece = option('marks', mark);
      final id = piece == null ? null : _piece(piece);
      if (id != null && !pieces.contains(id)) pieces.add(id);
    }
    return SheetLook(
      tints: tints,
      pieces: pieces,
      hairless: hairless,
      colors: colors,
    );
  }
}
