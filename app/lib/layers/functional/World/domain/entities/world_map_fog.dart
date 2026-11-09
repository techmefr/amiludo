import 'package:amiludo/layers/functional/World/domain/entities/map_element.dart';
import 'package:amiludo/layers/functional/World/domain/entities/map_pin.dart';
import 'package:amiludo/layers/functional/World/domain/entities/world_map.dart';

const revealRadius = gridCell * 2;

extension WorldMapFog on WorldMap {
  bool isRevealed(String floorId, WorldPoint p) {
    final f = floor(floorId);
    if (f == null) return false;
    return f.reveals.any((r) => r.distanceTo(p) <= revealRadius);
  }

  WorldMap toggleReveal(String floorId, WorldPoint p) {
    final f = floor(floorId);
    if (f == null) return this;
    final inside = f.reveals.any((r) => r.distanceTo(p) <= revealRadius);
    final next = inside
        ? [
            for (final r in f.reveals)
              if (r.distanceTo(p) > revealRadius) r,
          ]
        : [...f.reveals, p];
    return copyWith(
      floors: [
        for (final x in floors) x.id == floorId ? x.copyWith(reveals: next) : x,
      ],
    );
  }

  List<MapPin> visiblePins(String floorId, {required bool player}) {
    final f = floor(floorId);
    if (f == null) return const [];
    if (!player) return f.pins;
    return [
      for (final p in f.pins)
        if (!p.secret && (!fog || isRevealed(floorId, p.point))) p,
    ];
  }
}
