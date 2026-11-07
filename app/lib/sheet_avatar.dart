import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue.dart';
import 'package:amiludo/layers/functional/Companion/data/avatar_catalogue_loader.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/avatar_look.dart';
import 'package:amiludo/layers/functional/Companion/presentation/avatar_creator_screen.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hero_avatar.dart';
import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_look.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

AvatarLook _stored(Map<String, Object?>? json) =>
    AvatarLook.fromJson(json == null ? null : Map<String, dynamic>.from(json));

Future<Map<String, Object?>?> editSheetAvatar(
  BuildContext context,
  SheetLook look,
  Map<String, Object?>? current,
) async {
  final catalogue = await loadAvatarCatalogue();
  final initial = catalogue.lookFor(
    tints: look.tints,
    pieces: look.pieces,
    hairless: look.hairless,
    base: _stored(current),
  );
  if (!context.mounted) return null;
  final result = await Navigator.of(context).push<AvatarLook>(
    MaterialPageRoute(
      builder: (_) =>
          AvatarCreatorScreen(initial: initial, catalogue: catalogue),
    ),
  );
  return result == null ? null : Map<String, Object?>.from(result.toJson());
}

Widget sheetAvatarPreview(Map<String, Object?> avatar) =>
    _AvatarPreview(look: _stored(avatar));

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.look});
  final AvatarLook look;

  @override
  Widget build(BuildContext context) => FutureBuilder<AvatarCatalogue>(
    future: loadAvatarCatalogue(),
    builder: (context, snapshot) {
      final catalogue = snapshot.data;
      return SizedBox(
        height: 12 * Space.xl,
        child: catalogue == null
            ? const SizedBox.shrink()
            : HeroAvatar(look: look, catalogue: catalogue),
      );
    },
  );
}
