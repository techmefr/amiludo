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

void main() {
  test('layers only depend on what OSDD allows', () {
    expect(_importsByFile(), isNotEmpty);
    expect(_violations(), isEmpty);
  });
}
