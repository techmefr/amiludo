import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_layer.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_painter.dart';
import 'package:amiludo/layers/technical/Theme/components/aura/aura_presets.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';

const Duration auraDriftStep = Duration(seconds: 16);
const Duration auraDriftTravel = Duration(seconds: 12);
const double auraDriftScale = 1.14;
const double auraDriftReach = .035;

class AuraBackground extends StatefulWidget {
  const AuraBackground({
    super.key,
    this.preset,
    this.theme,
    this.base,
    this.animate = true,
  });
  final AuraPreset? preset;
  final ThemeData? theme;
  final Color? base;
  final bool animate;

  @override
  State<AuraBackground> createState() => _AuraBackgroundState();
}

class _AuraBackgroundState extends State<AuraBackground> {
  Timer? _timer;
  Offset _target = Offset.zero;
  int _step = 0;

  ThemeData get _theme => widget.theme ?? Theme.of(context);

  AuraPreset get _preset =>
      widget.preset ??
      AuraPresets.skin(_theme.extension<DeckStyle>()?.skin ?? 'clean');

  bool get _moving =>
      widget.animate &&
      _preset.drift > 0 &&
      !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AuraBackground old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (_moving) {
      _timer ??= Timer.periodic(auraDriftStep, (_) => _advance());
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _advance() {
    if (!mounted || !TickerMode.valuesOf(context).enabled) return;
    final reach = auraDriftReach * _preset.drift;
    setState(() {
      _step++;
      _target = Offset(math.sin(_step * 1.7), math.cos(_step * 1.1)) * reach;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _drifting(Widget layer) => TweenAnimationBuilder<Offset>(
    tween: Tween<Offset>(end: _target),
    duration: auraDriftTravel,
    curve: Curves.easeInOut,
    child: layer,
    builder: (context, shift, cached) {
      final size = MediaQuery.sizeOf(context);
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.translationValues(
          shift.dx * size.width,
          shift.dy * size.height,
          0,
        )..scaleByDouble(auraDriftScale, auraDriftScale, 1, 1),
        child: cached,
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = _theme, preset = _preset;
    final layer = RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: AuraPainter(
          layers: preset.layers(theme.brightness == Brightness.dark),
          scheme: theme.colorScheme,
          base: widget.base ?? theme.scaffoldBackgroundColor,
        ),
      ),
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _moving ? _drifting(layer) : layer,
              if (preset.grain > 0)
                RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: AuraGrainPainter(preset.grain),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
