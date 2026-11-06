import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_icon_picker.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_image_source.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef FaceEdit = ({DieFaceContent face, Map<String, List<int>> images});

Future<FaceEdit?> showFaceSheet(
  BuildContext context,
  DieDesign design,
  int index,
) => showDeckSheet<FaceEdit>(
  context: context,
  title: context.l10n.diceFaceEdit(index + 1),
  builder: (_) => DieFaceForm(design: design, index: index),
);

class DieFaceForm extends StatefulWidget {
  const DieFaceForm({super.key, required this.design, required this.index});
  final DieDesign design;
  final int index;

  @override
  State<DieFaceForm> createState() => _DieFaceFormState();
}

class _DieFaceFormState extends State<DieFaceForm> {
  late DieFaceContent face = widget.design.faces[widget.index];
  late final text = TextEditingController(
    text: face.kind == DieFaceKind.text ? face.value : '',
  );
  final images = <String, List<int>>{};

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  void pickImage(String id, List<int> bytes) {
    images[id] = bytes;
    setState(() => face = face.copyWith(kind: DieFaceKind.image, value: id));
  }

  DieImageReader reader(BuildContext context) => (id) async {
    final bytes = images[id];
    return bytes == null ? null : Uint8List.fromList(bytes);
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<DieFaceKind>(
          segments: [
            ButtonSegment(value: DieFaceKind.text, label: Text(l.diceFaceText)),
            ButtonSegment(value: DieFaceKind.icon, label: Text(l.diceFaceIcon)),
            ButtonSegment(
              value: DieFaceKind.image,
              label: Text(l.diceFaceImage),
            ),
          ],
          selected: {face.kind},
          onSelectionChanged: (s) => setState(
            () => face = DieFaceContent(
              kind: s.first,
              value: s.first == face.kind ? face.value : '',
              color: face.color,
            ),
          ),
        ),
        const SizedBox(height: Space.lg),
        if (face.kind == DieFaceKind.text)
          TextField(
            controller: text,
            maxLength: maxFaceText,
            decoration: InputDecoration(labelText: l.diceFaceText),
            onChanged: (v) => setState(() => face = face.copyWith(value: v)),
          ),
        if (face.kind == DieFaceKind.icon)
          DieIconPicker(
            selected: face.value,
            onPick: (id) => setState(() => face = face.copyWith(value: id)),
          ),
        if (face.kind == DieFaceKind.image)
          DieImageSource(
            current: face.value,
            reader: reader(context),
            onPick: pickImage,
          ),
        const SizedBox(height: Space.lg),
        Text(l.diceTrayCustomColor),
        Wrap(
          spacing: Space.sm,
          children: [
            for (final c in facePalette)
              IconButton(
                tooltip: l.diceTrayCustomColor,
                constraints: const BoxConstraints.tightFor(
                  width: Targets.minimum,
                  height: Targets.minimum,
                ),
                onPressed: () => setState(() => face = face.copyWith(color: c)),
                icon: Icon(
                  c == face.color ? Icons.check_circle : Icons.circle,
                  color: Color(c),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        FilledButton(
          onPressed: face.value.trim().isEmpty
              ? null
              : () => Navigator.pop(context, (face: face, images: images)),
          child: Text(l.themeSave),
        ),
      ],
    );
  }
}
