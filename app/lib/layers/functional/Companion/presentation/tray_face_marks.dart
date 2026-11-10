import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/die_design.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_face_view.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class TrayFaceMarks extends StatelessWidget {
  const TrayFaceMarks({
    super.key,
    required this.dice,
    required this.values,
    this.reader,
  });
  final List<DiceSpec> dice;
  final List<int> values;
  final DieImageReader? reader;

  @override
  Widget build(BuildContext context) {
    final marks = [
      for (var i = 0; i < dice.length && i < values.length; i++)
        if (values[i] >= 1 && values[i] <= dice[i].sides)
          if (dice[i].faceContent(values[i]).kind != DieFaceKind.text)
            DieFaceView(
              face: dice[i].faceContent(values[i]),
              body: Color(dice[i].color),
              size: Targets.minimum,
              reader: reader,
            ),
    ];
    if (marks.isEmpty) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: Wrap(alignment: WrapAlignment.center, children: marks),
    );
  }
}
