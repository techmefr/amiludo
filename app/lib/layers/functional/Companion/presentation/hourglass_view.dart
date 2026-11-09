import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/hourglass.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/technical/Theme/components/sand_scene.dart';
import 'package:amiludo/layers/technical/Theme/components/sandglass_painter.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const _fineTick = Duration(milliseconds: 100);
const _coarseTick = Duration(seconds: 1);

String clockText(Duration value) {
  final total = (value.inMilliseconds / 1000).ceil();
  final minutes = (total ~/ 60).toString().padLeft(2, '0');
  final seconds = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class HourglassView extends StatefulWidget {
  const HourglassView({
    super.key,
    required this.settings,
    this.sensor = const NoTurnSensor(),
    this.onTurned,
  });
  final HourglassSettings settings;
  final TurnSensor sensor;
  final VoidCallback? onTurned;

  @override
  State<HourglassView> createState() => _HourglassViewState();
}

class _HourglassViewState extends State<HourglassView> {
  late HourglassState flow = HourglassState(widget.settings);
  StreamSubscription<void>? subscription;
  Timer? ticker;
  Duration step = _fineTick;

  @override
  void initState() {
    super.initState();
    listenForTurns();
  }

  void listenForTurns() {
    subscription?.cancel();
    subscription = widget.sensor.turns.listen(
      (_) => turn(),
      onError: (Object _) {},
      cancelOnError: true,
    );
  }

  @override
  void didUpdateWidget(HourglassView old) {
    super.didUpdateWidget(old);
    if (old.sensor != widget.sensor) listenForTurns();
    if (old.settings != widget.settings) {
      stopTicker();
      flow = HourglassState(widget.settings);
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    ticker?.cancel();
    super.dispose();
  }

  void stopTicker() {
    ticker?.cancel();
    ticker = null;
  }

  void startTicker() {
    ticker?.cancel();
    ticker = Timer.periodic(step, (_) {
      setState(() => flow.tick(step));
      if (!flow.running) stopTicker();
    });
  }

  void apply(VoidCallback change) {
    setState(change);
    if (flow.running) {
      startTicker();
    } else {
      stopTicker();
    }
  }

  void turn() {
    if (!mounted) return;
    apply(flow.turn);
    widget.onTurned?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final wanted = reduced ? _coarseTick : _fineTick;
    if (wanted != step) {
      step = wanted;
      if (flow.running) startTicker();
    }
    final l10n = context.l10n;
    final height = (MediaQuery.sizeOf(context).height * 0.45).clamp(
      200.0,
      420.0,
    );
    final status = switch (flow.phase) {
      HourglassPhase.finished => l10n.hourglassDone,
      _ => clockText(flow.remaining),
    };
    return Semantics(
      container: true,
      liveRegion: flow.finished,
      label: '${l10n.toolHourglassTitle} $status',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: turn,
            onVerticalDragEnd: (_) => turn(),
            child: SizedBox(
              height: height,
              width: height * 0.6,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(flow.turns),
                tween: Tween(begin: flow.turns == 0 ? 1 : 0, end: 1),
                duration: Motion.of(context, Motion.slow),
                curve: Motion.curve,
                builder: (context, progress, child) => Transform.rotate(
                  angle: math.pi * (1 - progress),
                  child: child,
                ),
                child: CustomPaint(
                  painter: SandglassPainter(
                    upperFill: flow.upperFill,
                    lowerFill: flow.lowerFill,
                    sand: Color.lerp(
                      SandPalette.alert,
                      Color(widget.settings.color),
                      (flow.upperFill * 3).clamp(0.0, 1.0),
                    )!,
                    streaming: flow.running && !reduced,
                    phase: (flow.remaining.inMilliseconds % 1000) / 1000,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Text(status, style: sandNumerals(TypeScale.display * 1.6)),
          const SizedBox(height: Space.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.md,
            runSpacing: Space.sm,
            children: [
              SandPill(
                filled: true,
                onPressed: flow.finished
                    ? null
                    : () => apply(flow.running ? flow.pause : flow.start),
                label: flow.running ? l10n.hourglassPause : l10n.hourglassStart,
              ),
              SandPill(onPressed: turn, label: l10n.hourglassTurn),
              SandPill(
                onPressed: () => apply(flow.reset),
                label: l10n.appearanceReset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
