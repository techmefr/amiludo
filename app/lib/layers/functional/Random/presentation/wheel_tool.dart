import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/functional/Random/presentation/wheel_painter.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class WheelTool extends StatefulWidget {
  const WheelTool({super.key, required this.names});
  final List<String> names;
  @override
  State<WheelTool> createState() => _WheelToolState();
}

class _WheelToolState extends State<WheelTool>
    with SingleTickerProviderStateMixin {
  final random = RandomTools();
  late final TextEditingController options = TextEditingController(
    text: widget.names.join(', '),
  );
  late final AnimationController spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  Animation<double>? rotation;
  double angle = 0;
  List<String> labels = [];
  String result = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    spin.duration = Duration(
      milliseconds: MediaQuery.of(context).disableAnimations ? 1 : 1600,
    );
  }

  @override
  void dispose() {
    options.dispose();
    spin.dispose();
    super.dispose();
  }

  void draw() {
    try {
      final wheel = WheelOptions.parse(options.text);
      final index = random.weighted(
        List.generate(wheel.labels.length, (i) => i),
        wheel.weights,
      );
      spinTo(wheel.labels, index);
    } on RandomInputError catch (error) {
      notify(context, randomInputErrorText(context, error));
    }
  }

  void spinTo(List<String> drawn, int index) {
    final start = angle;
    angle +=
        pi * 8 +
        (2 * pi - angle % (2 * pi)) +
        (2 * pi - (index + .5) * 2 * pi / drawn.length);
    setState(() {
      labels = drawn;
      result = '';
      rotation = Tween<double>(
        begin: start,
        end: angle,
      ).animate(CurvedAnimation(parent: spin, curve: Curves.easeOutCubic));
    });
    spin.forward(from: 0).then((_) {
      if (mounted) setState(() => result = drawn[index]);
    });
  }

  List<String> shownLabels() {
    if (labels.isNotEmpty) return labels;
    try {
      return WheelOptions.parse(options.text).labels;
    } on RandomInputError {
      return parseOptions(options.text);
    }
  }

  Widget wheel(ThemeData theme) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Space.lg),
    child: LayoutBuilder(
      builder: (context, box) {
        final side = min(box.maxWidth, 360.0);
        return Column(
          children: [
            SizedBox(
              width: Space.xxl,
              height: Space.xl,
              child: const CustomPaint(painter: WheelPointer()),
            ),
            const SizedBox(height: Space.xs),
            AnimatedBuilder(
              animation: spin,
              builder: (context, child) =>
                  Transform.rotate(angle: rotation?.value ?? 0, child: child),
              child: CustomPaint(
                size: Size.square(side),
                painter: WheelPainter(shownLabels()),
              ),
            ),
            const SizedBox(height: Space.md),
            Text(
              context.l10n.randomWeightsAffectTheDrawNot,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      RandomOptionsField(
        controller: options,
        label: context.l10n.randomCommaSeparatedOptions,
        helper: context.l10n.randomOptionalWeightsCamille2Alex,
        onChanged: () => setState(() => result = ''),
      ),
      wheel(Theme.of(context)),
      if (result.isNotEmpty) RandomResult(text: result),
      RandomDrawButton(onPressed: spin.isAnimating ? null : draw),
    ],
  );
}
