import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/hourglass.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/turn_sensor.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_painter.dart';
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
    subscription = widget.sensor.turns.listen((_) => turn());
  }

  @override
  void didUpdateWidget(HourglassView old) {
    super.didUpdateWidget(old);
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
    final theme = Theme.of(context);
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
          SizedBox(
            height: height,
            width: height * 0.6,
            child: CustomPaint(
              painter: HourglassPainter(
                upperFill: flow.upperFill,
                lowerFill: flow.lowerFill,
                sand: Color(widget.settings.color),
                glass: theme.colorScheme.onSurface,
                streaming: flow.running && !reduced,
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Text(status, style: theme.textTheme.displaySmall),
          const SizedBox(height: Space.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Space.md,
            runSpacing: Space.sm,
            children: [
              FilledButton(
                onPressed: flow.finished
                    ? null
                    : () => apply(flow.running ? flow.pause : flow.start),
                child: Text(
                  flow.running ? l10n.hourglassPause : l10n.hourglassStart,
                ),
              ),
              OutlinedButton(onPressed: turn, child: Text(l10n.hourglassTurn)),
              TextButton(
                onPressed: () => apply(flow.reset),
                child: Text(l10n.appearanceReset),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
