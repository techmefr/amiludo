import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/oracle.dart';
import 'package:amiludo/layers/functional/Random/presentation/count_stepper.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_back.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_face.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_flip.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class OracleTool extends StatefulWidget {
  const OracleTool({super.key, this.random});
  final Random? random;

  @override
  State<OracleTool> createState() => _OracleToolState();
}

class _OracleToolState extends State<OracleTool> {
  final tool = toolThemeFor('oracle');
  late final Random _random = widget.random ?? Random.secure();
  OracleLikelihood likelihood = OracleLikelihood.even;
  int chaos = defaultChaos;
  OracleVerdict? verdict;
  int _asked = 0;

  void _ask() {
    tool.signal();
    setState(() {
      _asked++;
      verdict = askOracle(_random, likelihood, chaos);
    });
  }

  String _label(OracleLikelihood value) {
    final l = context.l10n;
    return switch (value) {
      OracleLikelihood.unlikely => l.oracleUnlikely,
      OracleLikelihood.even => l.oracleEven,
      OracleLikelihood.likely => l.oracleLikely,
    };
  }

  String _answer(OracleAnswer answer) {
    final l = context.l10n;
    return switch (answer) {
      OracleAnswer.yes => l.oracleYes,
      OracleAnswer.no => l.oracleNo,
      OracleAnswer.exceptionalYes => l.oracleExceptionalYes,
      OracleAnswer.exceptionalNo => l.oracleExceptionalNo,
    };
  }

  TarotStyle _style(OracleAnswer answer) => switch (answer) {
    OracleAnswer.yes => TarotStyle.forestGreen,
    OracleAnswer.no => TarotStyle.bloodRed,
    _ => TarotStyle.nightGold,
  };

  Widget _result(OracleVerdict value) {
    final style = _style(value.answer);
    return Center(
      child: Semantics(
        liveRegion: true,
        child: TarotFlip(
          key: ValueKey(_asked),
          flipped: true,
          sheen: style.glow,
          back: TarotBack(style: style, width: 190),
          front: TarotFace(
            title: _answer(value.answer),
            description: value.event ? context.l10n.oracleEvent : null,
            style: style,
            width: 190,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final shown = verdict;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.oracleLikelihood),
            const SizedBox(height: Space.sm),
            SegmentedButton<OracleLikelihood>(
              segments: [
                for (final v in OracleLikelihood.values)
                  ButtonSegment(value: v, label: Text(_label(v))),
              ],
              selected: {likelihood},
              onSelectionChanged: (s) => setState(() => likelihood = s.first),
            ),
            const SizedBox(height: Space.lg),
            CountStepper(
              label: l.oracleChaos,
              value: chaos,
              minimum: minChaos,
              maximum: maxChaos,
              lessTooltip: l.oracleChaosLess,
              moreTooltip: l.oracleChaosMore,
              onChanged: (v) => setState(() => chaos = v),
            ),
            const SizedBox(height: Space.xl),
            FilledButton(onPressed: _ask, child: Text(l.oracleAsk)),
            const SizedBox(height: Space.xl),
            if (shown != null) _result(shown),
          ],
        ),
      ),
    );
  }
}
