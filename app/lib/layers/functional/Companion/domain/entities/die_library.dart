import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';

enum ClashPolicy { replace, keepBoth }

class DieLibrary {
  const DieLibrary([this.designs = const []]);

  factory DieLibrary.fromJson(Map<String, dynamic> j) => DieLibrary([
    for (final d in j['designs'] as List? ?? const [])
      DieDesign.fromJson(Map<String, dynamic>.from(d as Map)),
  ]);

  final List<DieDesign> designs;

  DieDesign? byId(String? id) {
    for (final d in designs) {
      if (d.id == id) return d;
    }
    return null;
  }

  bool has(String id) => byId(id) != null;

  DieLibrary upsert(DieDesign design) => has(design.id)
      ? DieLibrary([for (final d in designs) d.id == design.id ? design : d])
      : DieLibrary([...designs, design]);

  DieLibrary remove(String id) =>
      DieLibrary([for (final d in designs) if (d.id != id) d]);

  Set<String> clashes(Iterable<DieDesign> incoming) => {
    for (final d in incoming)
      if (has(d.id)) d.id,
  };

  DieLibrary merge(
    Iterable<DieDesign> incoming,
    ClashPolicy policy,
    String Function() newId,
  ) {
    var next = this;
    for (final d in incoming) {
      if (!next.has(d.id)) {
        next = next.upsert(d);
      } else if (policy == ClashPolicy.replace) {
        next = next.upsert(d);
      } else {
        next = next.upsert(d.copyWith(id: newId()));
      }
    }
    return next;
  }

  Map<String, Object?> toJson() => {
    'designs': designs.map((d) => d.toJson()).toList(),
  };
}
