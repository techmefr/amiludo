import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tray_result.dart';

DiceTraySession session(List<int> values) => DiceTraySession(
  settings: DiceTraySettings(
    dice: [for (final _ in values) const DiceSpec(sides: 20)],
  ),
  values: values,
);

String show(TrayResultMode mode, List<int> values) =>
    trayResultText(mode, session(values), oddEven: (odd, even) => '$odd/$even');

void main() {
  test('each display mode reads the thrown values', () {
    final v = [2, 5, 3, 8];
    expect(show(TrayResultMode.none, v), '');
    expect(show(TrayResultMode.list, v), '2 · 5 · 3 · 8');
    expect(show(TrayResultMode.combined, v), '2 + 5 + 3 + 8 = 18');
    expect(show(TrayResultMode.sum, v), '18');
    expect(show(TrayResultMode.best, v), '8');
    expect(show(TrayResultMode.worst, v), '2');
    expect(show(TrayResultMode.dropWorst, v), '16');
    expect(show(TrayResultMode.dropBest, v), '10');
    expect(show(TrayResultMode.middle, v), '4');
    expect(show(TrayResultMode.average, v), '4.5');
    expect(show(TrayResultMode.oddEven, v), '2/2');
  });

  test(
    'a single die keeps its value when dropping and odd counts pick the middle',
    () {
      expect(show(TrayResultMode.dropWorst, [7]), '7');
      expect(show(TrayResultMode.dropBest, [7]), '7');
      expect(show(TrayResultMode.middle, [9, 1, 4]), '4');
    },
  );

  test('nothing is shown before the first throw', () {
    final empty = DiceTraySession(settings: const DiceTraySettings());
    expect(
      trayResultText(TrayResultMode.sum, empty, oddEven: (odd, even) => ''),
      '',
    );
  });
}
