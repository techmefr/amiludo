import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_look.dart';

typedef AvatarEditor = Future<Map<String, Object?>?> Function(
  BuildContext context,
  SheetLook look,
  Map<String, Object?>? current,
);

typedef AvatarPreview = Widget Function(Map<String, Object?> avatar);
