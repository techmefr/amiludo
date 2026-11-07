import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';

enum TrayResultMode {
  none,
  list,
  combined,
  sum,
  best,
  worst,
  dropWorst,
  dropBest,
  middle,
  average,
  oddEven;

  static TrayResultMode parse(String? name) =>
      values.firstWhere((m) => m.name == name, orElse: () => sum);
}

String _number(double value) =>
    value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(1);

List<int> _scores(DiceTraySession session) => [
  for (var i = 0; i < session.values.length; i++)
    ?session.settings.dice[i].scoreOf(session.values[i]),
];

String trayResultText(
  TrayResultMode mode,
  DiceTraySession session, {
  required String Function(int odd, int even) oddEven,
}) {
  if (!session.thrown || mode == TrayResultMode.none) return '';
  final labels = [
    for (var i = 0; i < session.values.length; i++)
      session.settings.dice[i].faceLabel(session.values[i]),
  ];
  final scores = _scores(session)..sort();
  if (mode == TrayResultMode.list) return labels.join(' · ');
  if (mode == TrayResultMode.combined) {
    return '${labels.join(' + ')} = ${session.total}';
  }
  if (scores.isEmpty) return '–';
  final total = scores.fold<int>(0, (a, b) => a + b);
  final middle = scores.length ~/ 2;
  return switch (mode) {
    TrayResultMode.best => '${scores.last}',
    TrayResultMode.worst => '${scores.first}',
    TrayResultMode.dropWorst => '${scores.length > 1 ? total - scores.first : total}',
    TrayResultMode.dropBest => '${scores.length > 1 ? total - scores.last : total}',
    TrayResultMode.middle => scores.length.isOdd
        ? '${scores[middle]}'
        : _number((scores[middle - 1] + scores[middle]) / 2),
    TrayResultMode.average => _number(total / scores.length),
    TrayResultMode.oddEven => oddEven(
      scores.where((s) => s.isOdd).length,
      scores.where((s) => s.isEven).length,
    ),
    _ => '${session.total}',
  };
}
