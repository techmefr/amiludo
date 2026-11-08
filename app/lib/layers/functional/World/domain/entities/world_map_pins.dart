import 'dart:math';

import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_atlas.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';

String formatMeters(double meters) {
  if (meters >= 1000) {
    final km = meters / 1000;
    return '${km >= 10 ? km.round() : km.toStringAsFixed(1)} km';
  }
  return '${max(1, meters.round())} m';
}

extension WorldMapPins on WorldMap {
  double metersBetween(WorldPoint a, WorldPoint b) =>
      a.distanceTo(b) / gridCell * level.cellMeters;

  WorldMap _pins(
    String floorId,
    List<MapPin> Function(List<MapPin>) change,
  ) => copyWith(
    floors: [
      for (final f in floors)
        f.id == floorId ? f.copyWith(pins: change(f.pins)) : f,
    ],
  );

  WorldMap addPin(String floorId, MapPin pin) =>
      _pins(floorId, (pins) => [...pins, pin]);

  WorldMap updatePin(MapPin next) => copyWith(
    floors: [
      for (final f in floors)
        f.copyWith(
          pins: [for (final p in f.pins) p.id == next.id ? next : p],
        ),
    ],
  );

  WorldMap removePin(String pinId) => copyWith(
    floors: [
      for (final f in floors)
        f.copyWith(
          pins: [
            for (final p in f.pins)
              if (p.id != pinId) p,
          ],
        ),
    ],
  );
}

class PinHit {
  const PinHit(this.map, this.floor, this.pin);
  final WorldMap map;
  final MapFloor floor;
  final MapPin pin;
}

extension WorldAtlasSearch on WorldAtlas {
  List<PinHit> searchPins(String query) {
    final needle = foldText(query.trim());
    return [
      for (final m in maps)
        for (final f in m.floors)
          for (final p in f.pins)
            if (needle.isEmpty ||
                foldText(p.title).contains(needle) ||
                foldText(p.note).contains(needle))
              PinHit(m, f, p),
    ];
  }

  Map<String, String> placeNamesByScene() => {
    for (final m in maps)
      for (final f in m.floors)
        for (final p in f.pins)
          if (p.kind == PinKind.scene && p.refId != null) p.refId!: p.title,
  };
}
