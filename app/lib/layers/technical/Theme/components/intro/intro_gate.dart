import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/intro/intro_overlay.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_timeline.dart';

class IntroGate extends StatefulWidget {
  const IntroGate({
    super.key,
    required this.child,
    required this.words,
    required this.skipLabel,
    this.onDone,
  });

  static bool enabled = true;
  static bool _played = false;

  static void resetSession() => _played = false;

  final Widget child;
  final List<String> words;
  final String skipLabel;
  final VoidCallback? onDone;

  @override
  State<IntroGate> createState() => _IntroGateState();
}

class _IntroGateState extends State<IntroGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: IntroTimeline.total,
  )..addStatusListener(_onStatus);
  bool _active = IntroGate.enabled && !IntroGate._played;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (_active && MediaQuery.disableAnimationsOf(context)) _active = false;
    if (_active) {
      _controller.forward();
    } else {
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onDone?.call(),
      );
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_active) return;
    IntroGate._played = true;
    setState(() => _active = false);
    widget.onDone?.call();
  }

  void _skip() {
    if (!_active || _controller.value >= 1) return;
    if (_controller.value < IntroTimeline.skipTo) {
      _controller.value = IntroTimeline.skipTo;
    }
    _controller.animateTo(
      1,
      duration: IntroTimeline.skipRun,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final e = IntroTimeline.span(
            _controller.value,
            IntroTimeline.zoomStart,
            IntroTimeline.revealEnd,
            IntroTimeline.expoInOut,
          );
          return Transform.translate(
            offset: Offset(0, 24 * (1 - e)),
            child: Transform.scale(scale: 1.06 - .06 * e, child: child),
          );
        },
      ),
      if (_active)
        IntroOverlay(
          animation: _controller,
          words: widget.words,
          skipLabel: widget.skipLabel,
          onSkip: _skip,
        ),
    ],
  );
}
