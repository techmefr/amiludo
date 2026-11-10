import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/finger_draw.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_layers.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/layers/technical/Theme/components/readable_on.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class FingerSurface extends StatelessWidget {
  const FingerSurface({
    super.key,
    required this.shown,
    required this.colors,
    required this.draw,
    required this.mode,
    required this.drawn,
    required this.epoch,
    required this.background,
    required this.hint,
    required this.onDown,
    required this.onMove,
    required this.onUp,
    this.subHint,
  });
  final Map<int, Offset> shown;
  final Map<int, int> colors;
  final FingerDraw draw;
  final FingerMode mode;
  final bool drawn;
  final int epoch;
  final Color background;
  final String hint;
  final String? subHint;
  final ValueChanged<PointerDownEvent> onDown;
  final ValueChanged<PointerMoveEvent> onMove;
  final ValueChanged<PointerEvent> onUp;

  Color _color(int id) {
    final group = draw.groups[id];
    final index = group == null ? colors[id] ?? 0 : group - 1;
    return fingerColorAt(index);
  }

  FingerRingState _state(int id) => mode == FingerMode.first && drawn
      ? (draw.winners.contains(id)
            ? FingerRingState.winner
            : FingerRingState.dim)
      : FingerRingState.idle;

  String? _label(int id) => (draw.ranks[id] ?? draw.groups[id])?.toString();

  String? _semantics(BuildContext context, int id) {
    final l = context.l10n;
    if (draw.winners.contains(id)) return l.fingerWinnerLabel;
    if (draw.ranks[id] != null) return l.fingerRankLabel(draw.ranks[id]!);
    if (draw.groups[id] != null) return l.fingerGroupLabel(draw.groups[id]!);
    return null;
  }

  Widget _at(Offset p, Widget child) => Positioned(
    left: p.dx - fingerRingSize / 2,
    top: p.dy - fingerRingSize / 2,
    width: fingerRingSize,
    height: fingerRingSize,
    child: OverflowBox(maxWidth: 4000, maxHeight: 4000, child: child),
  );

  List<Widget> _contact(BuildContext context, int id, Offset p, double reach) {
    final color = _color(id);
    final state = _state(id);
    return [
      if (state != FingerRingState.dim)
        _at(p, FingerHalo(key: ValueKey('halo-$id'), color: color)),
      if (!drawn)
        _at(
          p,
          FingerCountdownArc(key: ValueKey('arc-$id-$epoch'), color: color),
        ),
      if (drawn && state != FingerRingState.dim)
        _at(
          p,
          FingerShockwave(
            key: ValueKey('wave-$id-$epoch'),
            color: state == FingerRingState.winner
                ? fingerWinnerDiscColor
                : color,
            reach: reach,
          ),
        ),
      Positioned(
        key: ValueKey(id),
        left: p.dx - fingerRingSize / 2,
        top: p.dy - fingerRingSize / 2,
        child: Semantics(
          label: _semantics(context, id),
          child: FingerRing(
            color: color,
            nextColor: drawn ? null : fingerColorAt((colors[id] ?? 0) + 2),
            state: state,
            label: _label(id),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final onPad = background == fingerPadColor;
    final ink = onPad ? fingerHintColor : readableOn(background);
    final style = Theme.of(context).textTheme;
    final idle = shown.isEmpty && !drawn;
    return Listener(
      onPointerDown: onDown,
      onPointerMove: onMove,
      onPointerUp: onUp,
      onPointerCancel: onUp,
      child: AnimatedContainer(
        duration: Motion.of(context, Motion.slow),
        curve: Motion.curve,
        color: background,
        child: LayoutBuilder(
          builder: (context, box) => Semantics(
            container: true,
            label: context.l10n.fingerSurfaceLabel,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: idle ? Alignment.center : Alignment.bottomCenter,
                  child: Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.all(Space.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hint,
                            textAlign: TextAlign.center,
                            style: (idle ? style.titleLarge : style.bodyLarge)
                                ?.copyWith(color: ink),
                          ),
                          if (idle && subHint != null) ...[
                            const SizedBox(height: Space.sm),
                            Text(
                              subHint!,
                              textAlign: TextAlign.center,
                              style: style.bodyMedium?.copyWith(color: ink),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                for (final e in shown.entries)
                  ..._contact(context, e.key, e.value, box.biggest.longestSide),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
