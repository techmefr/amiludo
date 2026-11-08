import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/presentation/life_controller.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_details_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_palette.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_panel.dart';
import 'package:amiludo/layers/functional/Companion/presentation/life_setup_bar.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class LifeTool extends StatefulWidget {
  const LifeTool({super.key, required this.names});
  final List<String> names;

  @override
  State<LifeTool> createState() => _LifeToolState();
}

class _LifeToolState extends State<LifeTool> {
  late final LifeController controller = LifeController(
    widget.names.isEmpty ? const ['1', '2', '3', '4'] : widget.names,
  );
  final tool = toolThemeFor('life');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _panel(int index) {
    final player = controller.match.players[index];
    final panel = LifePanel(
      player: player,
      accent: playerTints[index % playerTints.length],
      onChange: (delta) {
        tool.signal();
        controller.life(index, delta);
      },
      onDetails: () => showLifeDetails(context, controller, index),
    );
    return Expanded(
      child: controller.match.players.length == 2 && index == 0
          ? RotatedBox(quarterTurns: 2, child: panel)
          : panel,
    );
  }

  Widget _grid(int count, bool wide) {
    final columns = count <= 2 ? (wide ? 2 : 1) : (wide ? (count + 1) ~/ 2 : 2);
    final rows = (count / columns).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < columns; c++)
                  if (r * columns + c < count) _panel(r * columns + c),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final count = controller.match.players.length;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.sm,
          Space.section,
          Space.sm,
          Space.sm,
        ),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) =>
                    _grid(count, box.maxWidth > box.maxHeight),
              ),
            ),
            LifeSetupBar(controller: controller),
          ],
        ),
      );
    },
  );
}
