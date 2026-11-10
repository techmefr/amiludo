import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_face_ops.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_face.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

const coinDesignId = 'amiludo-coin-faces';

DieDesign defaultCoin(BuildContext context) => DieDesign(
  id: coinDesignId,
  name: context.l10n.toolCoinTitle,
  faces: const [
    DieFaceContent(kind: DieFaceKind.icon, value: 'star'),
    DieFaceContent(kind: DieFaceKind.icon, value: 'diamond'),
  ],
);

DieFaceContent? customCoinFace(DieDesign design, int index) {
  if (design.sides != 2) return null;
  final face = design.faces[index];
  final original = index == 0 ? 'star' : 'diamond';
  return face.kind == DieFaceKind.icon &&
          face.value == original &&
          face.color == null
      ? null
      : face;
}

String coinSideLabel(BuildContext context, DieDesign design, int index) {
  final l = context.l10n;
  final side = index == 0 ? l.randomHeads : l.randomTails;
  final face = customCoinFace(design, index);
  return switch (face?.kind) {
    DieFaceKind.text => face!.value,
    DieFaceKind.icon => '$side (${face!.value.replaceAll('-', ' ')})',
    _ => side,
  };
}

class CoinFaceMenu extends StatelessWidget {
  const CoinFaceMenu({super.key, required this.design, required this.onSelect});
  final DieDesign design;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final reader = DieStudio.maybeOf(context)?.image;
    return PopupMenuButton<int>(
      tooltip: l.diceFaces,
      enabled: onSelect != null,
      onSelected: onSelect,
      icon: const Icon(Icons.edit_outlined),
      itemBuilder: (context) => [
        for (var i = 0; i < 2; i++)
          PopupMenuItem(
            value: i,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CoinFace(
                heads: i == 0,
                size: 40,
                face: customCoinFace(design, i),
                reader: reader,
              ),
              title: Text(i == 0 ? l.randomHeads : l.randomTails),
              subtitle: customCoinFace(design, i) == null
                  ? null
                  : Text(coinSideLabel(context, design, i)),
            ),
          ),
      ],
    );
  }
}

Future<DieDesign?> customizeCoin(
  BuildContext context,
  DieDesign design,
  int side,
) async {
  final studio = DieStudio.maybeOf(context);
  if (studio == null) return null;
  final l = context.l10n;
  final edited = await showFaceSheet(
    context,
    design,
    side,
    title: side == 0 ? l.randomHeads : l.randomTails,
  );
  if (edited == null || !context.mounted) return null;
  final saved = design.withFace(side, edited.face);
  await studio.save(saved, images: edited.images);
  return saved;
}
