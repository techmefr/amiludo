import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/technical/Drawing/drawing_pad.dart';
import 'package:amiludo/layers/technical/Drawing/png_encoding.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/deck_sheet.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<Uint8List?> showDrawingSheet(BuildContext context) =>
    showDeckSheet<Uint8List>(
      context: context,
      title: context.l10n.diceImageDraw,
      builder: (_) => const DrawingForm(),
    );

class DrawingForm extends StatefulWidget {
  const DrawingForm({super.key});

  @override
  State<DrawingForm> createState() => _DrawingFormState();
}

class _DrawingFormState extends State<DrawingForm> {
  final controller = DrawingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> use() async {
    final png = await renderDrawingPng(controller.strokes, 256);
    if (mounted) Navigator.pop(context, png);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget action(String tip, IconData icon, VoidCallback tap) => IconButton(
      tooltip: tip,
      constraints: const BoxConstraints.tightFor(
        width: Targets.minimum,
        height: Targets.minimum,
      ),
      icon: DeckIcon(icon),
      onPressed: tap,
    );
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Semantics(
              label: l.diceImageDraw,
              child: DrawingPad(controller: controller),
            ),
          ),
          const SizedBox(height: Space.md),
          Row(
            children: [
              action(l.diceDrawUndo, Icons.undo, controller.undo),
              action(l.diceDrawClear, Icons.delete_outline, controller.clear),
              Expanded(
                child: Slider(
                  min: 2,
                  max: 24,
                  value: controller.width,
                  label: l.diceDrawWidth,
                  semanticFormatterCallback: (v) =>
                      '${l.diceDrawWidth} ${v.round()}',
                  onChanged: controller.setWidth,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: Space.sm,
            children: [
              for (final c in [0xFF151515, ...facePalette])
                IconButton(
                  tooltip: l.diceDrawColor,
                  constraints: const BoxConstraints.tightFor(
                    width: Targets.minimum,
                    height: Targets.minimum,
                  ),
                  onPressed: () => controller.setColor(Color(c)),
                  icon: Icon(
                    controller.color == Color(c)
                        ? Icons.check_circle
                        : Icons.circle,
                    color: Color(c),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.md),
          FilledButton(
            onPressed: controller.isEmpty ? null : use,
            child: Text(l.diceDrawUse),
          ),
        ],
      ),
    );
  }
}
