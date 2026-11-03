import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';

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

  Widget wheel(ThemeData theme) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Center(
      child: Column(
        children: [
          DeckIcon(
            Icons.arrow_drop_down,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          AnimatedBuilder(
            animation: spin,
            builder: (context, child) =>
                Transform.rotate(angle: rotation?.value ?? 0, child: child),
            child: CustomPaint(
              size: const Size(240, 240),
              painter: WheelPainter(
                labels.isEmpty ? parseOptions(options.text) : labels,
                theme.colorScheme.primary,
                theme.colorScheme.surface,
                theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tr(
              context,
              'Les poids influencent le tirage, pas la taille des secteurs.',
              'Weights affect the draw, not sector sizes.',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RandomOptionsField(
        controller: options,
        label: tr(
          context,
          'Options séparées par des virgules',
          'Comma-separated options',
        ),
        helper: tr(
          context,
          'Poids facultatif : Camille:2, Alex:1',
          'Optional weights: Camille:2, Alex:1',
        ),
        onChanged: () => setState(() => result = ''),
      ),
      wheel(Theme.of(context)),
      if (result.isNotEmpty) RandomResult(text: result),
      RandomDrawButton(onPressed: spin.isAnimating ? null : draw),
    ],
  );
}

class WheelPainter extends CustomPainter {
  WheelPainter(this.labels, this.accent, this.background, this.ink);
  final List<String> labels;
  final Color accent, background, ink;
  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2),
        radius = size.width / 2,
        sweep = 2 * pi / labels.length;
    for (var i = 0; i < labels.length; i++) {
      final start = -pi / 2 + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        start,
        sweep,
        true,
        Paint()
          ..color = Color.lerp(background, accent, i.isEven ? 0.16 : 0.32)!,
      );
      canvas.drawLine(
        center,
        center + Offset(cos(start), sin(start)) * radius,
        Paint()..color = accent.withValues(alpha: .5),
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(start + sweep / 2);
      final text = TextPainter(
        text: TextSpan(
          text: labels[i].length > 12
              ? '${labels[i].substring(0, 11)}…'
              : labels[i],
          style: TextStyle(
            color: ink,
            fontSize: labels.length > 12 ? 9 : 12,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * .7);
      text.paint(canvas, Offset(radius * .24, -text.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(center, 16, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.labels != labels || old.accent != accent;
}
