import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/demo/demo_stage.dart';
import 'package:amiludo/layers/technical/Theme/components/demo/demo_timeline.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DemoPlayer extends StatefulWidget {
  const DemoPlayer({
    super.key,
    required this.pauseLabel,
    required this.playLabel,
    required this.color,
    required this.contrast,
    this.mockup = false,
  });

  static bool autoplay = true;

  final String pauseLabel;
  final String playLabel;
  final Color color;
  final Color contrast;
  final bool mockup;

  @override
  State<DemoPlayer> createState() => _DemoPlayerState();
}

class _DemoPlayerState extends State<DemoPlayer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DemoTimeline.loop,
  );
  ScrollPosition? _scroll;
  bool _userPaused = false;
  bool _visible = true;
  bool _foreground = true;
  bool _reduced = false;

  bool get _running =>
      DemoPlayer.autoplay &&
      !_reduced &&
      !_userPaused &&
      _visible &&
      _foreground;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisible());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scroll) {
      _scroll?.removeListener(_checkVisible);
      _scroll = position?..addListener(_checkVisible);
    }
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _checkVisible() {
    final box = context.findRenderObject();
    if (!mounted || box is! RenderBox || !box.attached || !box.hasSize) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final visible = rect.overlaps(Offset.zero & MediaQuery.sizeOf(context));
    if (visible == _visible) return;
    _visible = visible;
    _sync();
  }

  void _sync() {
    if (_reduced || !DemoPlayer.autoplay) {
      _controller.value = DemoTimeline.staticFrame;
    }
    if (_running) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop(canceled: false);
    }
    if (mounted) setState(() {});
  }

  void _toggle() {
    _userPaused = !_userPaused;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll?.removeListener(_checkVisible);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paused = !_running && !_reduced && _userPaused;
    return Semantics(
      button: true,
      label: _userPaused ? widget.playLabel : widget.pauseLabel,
      excludeSemantics: true,
      onTap: _toggle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Stack(
          children: [
            Positioned.fill(
              child: DemoStage(
                animation: _controller,
                color: widget.color,
                contrast: widget.contrast,
                mockup: widget.mockup,
              ),
            ),
            if (paused)
              Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: Targets.minimum,
                  color: widget.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
