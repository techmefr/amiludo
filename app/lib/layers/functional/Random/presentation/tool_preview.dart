import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/hourglass_painter.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/brick_catalog.dart';
import 'package:amiludo/layers/functional/Random/presentation/map_sketch_painter.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class ToolPreview extends StatefulWidget {
  const ToolPreview({super.key, required this.id, this.height = 120});
  final String id;
  final double height;

  @override
  State<ToolPreview> createState() => _ToolPreviewState();
}

class _ToolPreviewState extends State<ToolPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.slow * 4,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  void _replay() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _counter(BuildContext context, double t) {
    final preset = counterEntries.firstWhere((e) => e.id == widget.id).counter!;
    final target = preset.start == 0 ? 12 : preset.start.round();
    return Center(
      child: Text(
        '${(target * t).round()}',
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          fontFeatures: Numerals.tabular,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _hourglass(ToolTheme tool, Color ink, double t) => Center(
    child: AspectRatio(
      aspectRatio: .6,
      child: CustomPaint(
        painter: HourglassPainter(
          upperFill: 1 - .6 * t,
          lowerFill: .6 * t,
          sand: tool.accent,
          glass: ink,
          streaming: t < 1,
        ),
      ),
    ),
  );

  Widget _spin(double t) => Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..setEntry(3, 2, .002)
      ..rotateX((1 - t) * pi * 3),
    child: GameArt(tool: widget.id, height: widget.height),
  );

  Widget _frame(BuildContext context, double t) {
    final tool = toolThemeFor(widget.id);
    final ink = tool.ink(tool.surface(context));
    if (widget.id.startsWith(counterBrickPrefix)) return _counter(context, t);
    return switch (widget.id) {
      'hourglass' || 'timer' => _hourglass(tool, ink, t),
      'dice' || 'dice-tray' => Center(
        child: Transform.rotate(
          angle: (1 - t) * pi * 2,
          child: ExcludeSemantics(
            child: DieResult(value: 1 + (t * 4).floor() % 6),
          ),
        ),
      ),
      'map' => CustomPaint(
        painter: MapSketchPainter(progress: t, ink: ink, mark: tool.accent),
      ),
      'coin' || 'wheel' => _spin(t),
      _ => Opacity(
        opacity: .4 + .6 * t,
        child: GameArt(tool: widget.id, height: widget.height),
      ),
    };
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: MouseRegion(
      onEnter: (_) => _replay(),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) =>
              _frame(context, Curves.easeOutCubic.transform(_controller.value)),
        ),
      ),
    ),
  );
}
