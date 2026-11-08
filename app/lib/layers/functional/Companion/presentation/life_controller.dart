import 'package:flutter/foundation.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/life_match.dart';

class LifeController extends ChangeNotifier {
  LifeController(this._names, {int count = 4})
    : match = LifeMatch.begin(_pick(_names, count));

  final List<String> _names;
  LifeMatch match;
  final List<LifeMatch> _history = [];

  static List<String> _pick(List<String> names, int count) => [
    for (var i = 0; i < count; i++) names[i % names.length],
  ];

  bool get canUndo => _history.isNotEmpty;

  void _apply(LifeMatch next) {
    if (identical(next, match)) return;
    _history.add(match);
    match = next;
    notifyListeners();
  }

  void life(int index, int delta) => _apply(match.life(index, delta));

  void poison(int index, int delta) => _apply(match.poison(index, delta));

  void energy(int index, int delta) => _apply(match.energy(index, delta));

  void commander(int target, int source, int delta) =>
      _apply(match.commanderHit(target, source, delta));

  void restart({int? start}) => _apply(match.restart(start: start));

  void resize(int count) =>
      _apply(match.resized(count, _names).restart(start: match.start));

  void undo() {
    if (_history.isEmpty) return;
    match = _history.removeLast();
    notifyListeners();
  }
}
