import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _import = RegExp(
  r'''^import 'package:amiludo/layers/(\w+)/(\w+)/(\w+)''',
);

Map<String, List<String>> _importsByFile() {
  final files = Directory('lib/layers')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  return {
    for (final file in files)
      file.path.replaceAll(r'\', '/'): file.readAsLinesSync(),
  };
}

List<String> _violations() {
  final found = <String>[];
  for (final MapEntry(key: path, value: lines) in _importsByFile().entries) {
    final parts = path.split('/');
    final layer = parts[parts.indexOf('layers') + 1];
    final feature = parts[parts.indexOf('layers') + 2];
    for (final line in lines) {
      final match = _import.firstMatch(line);
      if (match == null) continue;
      final (targetLayer, targetFeature, part) = (
        match[1]!,
        match[2]!,
        match[3]!,
      );
      if (layer == 'technical' && targetLayer == 'functional') {
        found.add('$path -> $targetFeature');
      }
      if (layer == 'functional' &&
          targetLayer == 'functional' &&
          targetFeature != feature &&
          part != 'domain') {
        found.add('$path -> $targetFeature/$part');
      }
    }
  }
  return found;
}

Map<String, Set<String>> _domainGraph() {
  final graph = <String, Set<String>>{};
  for (final MapEntry(key: path, value: lines) in _importsByFile().entries) {
    final parts = path.split('/');
    final at = parts.indexOf('layers');
    if (parts[at + 1] != 'functional' || parts[at + 3] != 'domain') continue;
    final feature = parts[at + 2];
    for (final line in lines) {
      final match = _import.firstMatch(line);
      if (match == null || match[1] != 'functional') continue;
      if (match[2] == feature) continue;
      graph.putIfAbsent(feature, () => {}).add(match[2]!);
    }
  }
  return graph;
}

List<String> _cycles(Map<String, Set<String>> graph, Set<String> ignored) {
  final found = <String>{};
  void visit(List<String> path) {
    for (final next in graph[path.last] ?? const <String>{}) {
      if (ignored.contains(next)) continue;
      if (next == path.first) found.add([...path, next].join(' -> '));
      if (!path.contains(next)) visit([...path, next]);
    }
  }

  for (final start in graph.keys.where((k) => !ignored.contains(k))) {
    visit([start]);
  }
  return found.toList();
}

void main() {
  test('layers only depend on what OSDD allows', () {
    expect(_importsByFile(), isNotEmpty);
    expect(_violations(), isEmpty);
  });

  test('feature domains never depend on each other in a cycle', () {
    expect(_domainGraph(), isNotEmpty);
    expect(_cycles(_domainGraph(), {'Workspace'}), isEmpty);
  });
}
