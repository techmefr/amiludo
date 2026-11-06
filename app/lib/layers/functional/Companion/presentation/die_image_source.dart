import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_drawing_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Drawing/png_encoding.dart';
import 'package:amiludo/layers/technical/Files/file_transfer.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DieImageSource extends StatelessWidget {
  const DieImageSource({
    super.key,
    required this.current,
    required this.reader,
    required this.onPick,
    this.pickFile = FileTransfer.openImage,
  });
  final String current;
  final DieImageReader reader;
  final void Function(String id, List<int> bytes) onPick;
  final Future<Uint8List?> Function() pickFile;

  Future<void> importImage(BuildContext context) async {
    final raw = await pickFile();
    if (raw == null) return;
    final png = await downscaleToPng(raw);
    onPick(dieId(), png);
  }

  Future<void> draw(BuildContext context) async {
    final png = await showDrawingSheet(context);
    if (png != null) onPick(dieId(), png);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      children: [
        if (current.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: Space.md),
            child: DieFaceView(
              face: DieFaceContent(kind: DieFaceKind.image, value: current),
              body: Theme.of(context).colorScheme.surfaceContainerHighest,
              size: 72,
              reader: reader,
            ),
          ),
        Expanded(
          child: Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => importImage(context),
                icon: const DeckIcon(Icons.add_photo_alternate_outlined),
                label: Text(l.diceImageImport),
              ),
              OutlinedButton.icon(
                onPressed: () => draw(context),
                icon: const DeckIcon(Icons.edit_outlined),
                label: Text(l.diceImageDraw),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
