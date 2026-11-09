import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Feedback/deck_haptics.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/fan_card.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/light_burst_painter.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/opening_pack.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_idle.dart';
import 'package:amiludo/layers/technical/Theme/components/pack/pack_timing.dart';
import 'package:amiludo/layers/technical/Theme/components/tarot_style.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class PackStage extends StatefulWidget {
  const PackStage({
    super.key,
    required this.rarities,
    required this.faceBuilder,
    required this.packLabel,
    required this.cardLabel,
    this.autoOpen = false,
    this.style = TarotStyle.nightGold,
    this.onDone,
  });
  final List<double> rarities;
  final Widget Function(int index, double width) faceBuilder;
  final String packLabel, cardLabel;
  final bool autoOpen;
  final TarotStyle style;
  final VoidCallback? onDone;

  @override
  State<PackStage> createState() => _PackStageState();
}

class _PackStageState extends State<PackStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  Timer? _settle;
  bool _started = false, _initialised = false;
  int _beat = 0, _revealed = 0;

  int get _count => widget.rarities.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _open.value = 1;
    } else if (widget.autoOpen) {
      _begin();
    }
  }

  void _begin() {
    if (_started) return;
    setState(() => _started = true);
    _open.addListener(_haptics);
    _open.forward();
  }

  void _haptics() {
    final t = _open.value;
    const marks = [.06, .16, .26, .34];
    if (_beat < marks.length && t > marks[_beat]) {
      _beat++;
      DeckHaptics.selection();
    } else if (_beat == marks.length && t > PackBeat.shakeEnd) {
      _beat++;
      DeckHaptics.heavy();
    }
  }

  void _revealedOne() {
    if (++_revealed < _count) return;
    _settle = Timer(const Duration(milliseconds: 900), () {
      widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _settle?.cancel();
    _open.dispose();
    super.dispose();
  }

  Widget _card(int i, double t, double width, double step) {
    final offset = i - (_count - 1) / 2;
    final from = PackBeat.fanStart + .25 * i / _count;
    final f = Curves.easeOutBack.transform(packSpan(t, from, from + .2));
    return Transform.translate(
      offset: Offset(offset * step * f, offset * offset * width * .035 * f),
      child: Transform.rotate(
        angle: offset * .12 * f,
        alignment: Alignment.bottomCenter,
        child: Opacity(
          opacity: f.clamp(0.0, 1.0),
          child: FanCard(
            key: ValueKey('fan-card-$i'),
            width: width,
            rarity: widget.rarities[i],
            label: widget.cardLabel,
            style: widget.style,
            front: widget.faceBuilder(i, width),
            onRevealed: _revealedOne,
          ),
        ),
      ),
    );
  }

  Widget _stack(double t, double width, double step) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      if (!_started)
        PackIdle(
          width: width,
          label: widget.packLabel,
          style: widget.style,
          onTap: _begin,
        )
      else if (t < PackBeat.packGone)
        OpeningPack(progress: t, width: width, style: widget.style),
      if (_started && t >= PackBeat.fanStart)
        for (var i = 0; i < _count; i++) _card(i, t, width, step),
      if (_started)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: LightBurstPainter(
                progress: packSpan(t, PackBeat.burstStart, PackBeat.burstEnd),
                color: widget.style.glow,
              ),
            ),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final available = box.maxWidth.isFinite ? box.maxWidth : 360.0;
      final width = math.min(124.0, available * .34);
      final step = _count < 2
          ? 0.0
          : math.min(width * .62, (available - width) / (_count - 1));
      return SizedBox(
        height: width / tarotRatio * 1.45 + Space.lg,
        child: AnimatedBuilder(
          animation: _open,
          builder: (_, _) => _stack(_open.value, width, step),
        ),
      );
    },
  );
}
