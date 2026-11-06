const embeddedDiceKey = 'dice';

Set<String> collectDesignIds(Object? json) {
  final found = <String>{};
  void walk(Object? node) {
    if (node is Map) {
      for (final e in node.entries) {
        final v = e.value;
        if (e.key == 'design' && v is String) {
          found.add(v);
        } else if (e.key == 'design' && v is Map && v['id'] is String) {
          found.add(v['id'] as String);
        } else if (e.key != embeddedDiceKey) {
          walk(v);
        }
      }
    } else if (node is List) {
      node.forEach(walk);
    }
  }

  walk(json);
  return found;
}

Object? _rewriteSnapshot(
  Map<dynamic, dynamic> d,
  Map<String, String> designs,
  Map<String, String> images,
) => {
  for (final e in d.entries)
    e.key: switch (e.key) {
      'id' => designs[e.value] ?? e.value,
      'faces' when e.value is List => [
        for (final f in e.value as List)
          f is Map && f['kind'] == 'image'
              ? {...f, 'value': images[f['value']] ?? f['value']}
              : f,
      ],
      _ => e.value,
    },
};

Object? rewriteDesignRefs(
  Object? json,
  Map<String, String> designs,
  Map<String, String> images,
) {
  if (json is Map) {
    return {
      for (final e in json.entries)
        if (e.key != embeddedDiceKey)
          e.key: e.key == 'design' && e.value is String
              ? designs[e.value] ?? e.value
              : e.key == 'design' && e.value is Map
              ? _rewriteSnapshot(e.value as Map, designs, images)
              : rewriteDesignRefs(e.value, designs, images),
    };
  }
  if (json is List) {
    return [for (final v in json) rewriteDesignRefs(v, designs, images)];
  }
  return json;
}
