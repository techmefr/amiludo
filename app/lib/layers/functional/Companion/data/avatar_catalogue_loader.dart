import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue.dart';

Future<AvatarCatalogue> loadAvatarCatalogue([AssetBundle? bundle]) async {
  final source = bundle ?? rootBundle;
  return AvatarCatalogue.decode(
    await source.loadString('assets/avatar/items.json'),
    await source.loadString('assets/avatar/palettes.json'),
    await source.loadString('assets/avatar/rig.json'),
  );
}
