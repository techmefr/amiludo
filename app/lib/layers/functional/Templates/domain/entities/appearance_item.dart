class AppearanceLayer {
  const AppearanceLayer({required this.order, required this.src});
  final int order;
  final String src;
  Map<String, Object?> toJson() => {'order': order, 'src': src};
  factory AppearanceLayer.fromJson(Map<String, dynamic> j) =>
      AppearanceLayer(order: j['order'] as int, src: j['src'] as String);
}

class AppearanceVariant {
  const AppearanceVariant({
    this.layers = const [],
    this.hideBodyParts = const [],
  });
  final List<AppearanceLayer> layers;
  final List<String> hideBodyParts;
  Map<String, Object?> toJson() => {
    'layers': layers.map((l) => l.toJson()).toList(),
    'hideBodyParts': hideBodyParts,
  };
  factory AppearanceVariant.fromJson(Map<String, dynamic> j) =>
      AppearanceVariant(
        layers: (j['layers'] as List? ?? [])
            .map(
              (l) =>
                  AppearanceLayer.fromJson(Map<String, dynamic>.from(l as Map)),
            )
            .toList(),
        hideBodyParts: List<String>.from(j['hideBodyParts'] as List? ?? []),
      );
}

class AppearanceItem {
  const AppearanceItem({
    required this.id,
    required this.slot,
    required this.variants,
    this.peoples = const [],
  });
  final String id, slot;
  final List<String> peoples;
  final Map<String, AppearanceVariant> variants;

  bool fits(String morphology, String? people) =>
      variants.containsKey(morphology) &&
      (peoples.isEmpty || people == null || peoples.contains(people));

  Map<String, Object?> toJson() => {
    'id': id,
    'slot': slot,
    'peoples': peoples,
    'variants': variants.map((k, v) => MapEntry(k, v.toJson())),
  };
  factory AppearanceItem.fromJson(Map<String, dynamic> j) => AppearanceItem(
    id: j['id'] as String,
    slot: j['slot'] as String,
    peoples: List<String>.from(j['peoples'] as List? ?? []),
    variants: (j['variants'] as Map).map(
      (k, v) => MapEntry(
        k as String,
        AppearanceVariant.fromJson(Map<String, dynamic>.from(v as Map)),
      ),
    ),
  );
}
