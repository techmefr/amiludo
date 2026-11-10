import 'dart:math';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';

AvatarLook randomAvatarLook(AvatarCatalogue catalogue, Random random) {
  final tints = {
    for (final e in catalogue.palettes.entries)
      e.key: random.nextInt(e.value.length),
  };
  final optional = catalogue.rig?.optional ?? const <String>{};
  final picks = <String>[];
  for (final slot in catalogue.slots) {
    final items = catalogue.itemsFor(slot);
    if (items.isEmpty) continue;
    if (optional.contains(slot) && random.nextInt(3) != 0) continue;
    picks.add(items[random.nextInt(items.length)].id);
  }
  return catalogue.lookFor(
    tints: tints,
    pieces: picks,
    hairless: !picks.any((id) => id.startsWith('hair.')),
    base: const AvatarLook(),
  );
}
