import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';

extension BrickIds on Iterable<Brick> {
  Brick withFreeId(Brick brick) {
    final taken = map((b) => b.id).toSet();
    var id = brick.id;
    for (var n = 2; taken.contains(id); n++) {
      id = '${brick.id}-$n';
    }
    return Brick(
      id: id,
      type: brick.type,
      settings: brick.settings,
      ownerKind: brick.ownerKind,
      ownerId: brick.ownerId,
      extra: brick.extra,
    );
  }
}
