import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_dock.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_draw.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_hints.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_sheet.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_surface.dart';
import 'package:amiludo/layers/technical/Display/fullscreen.dart';
import 'package:amiludo/layers/technical/Feedback/device_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_layers.dart';
import 'package:amiludo/layers/technical/Theme/components/finger_ring.dart';
import 'package:amiludo/layers/technical/Theme/components/fullscreen_button.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';

const int _firstVirtual = 1 << 20;
const int _maxVirtual = 10;

class FingerTool extends StatefulWidget {
  const FingerTool({
    super.key,
    required this.names,
    this.haptics = true,
    this.onTint,
  });
  final bool haptics;
  final List<String> names;
  final ValueChanged<Color?>? onTint;
  @override
  State<FingerTool> createState() => _FingerToolState();
}

class _FingerToolState extends State<FingerTool> {
  final contacts = <int, Offset>{};
  final colors = <int, int>{};
  final frozen = <int, Offset>{};
  final virtual = <int>{};
  final random = RandomTools();
  Timer? countdown;
  FingerMode mode = FingerMode.first;
  FingerDraw draw = const FingerDraw();
  int winners = 1, groups = 2, arrivals = 0, epoch = 0, seq = _firstVirtual;
  bool drawn = false;

  void schedule() {
    countdown?.cancel();
    if (contacts.isEmpty || drawn) return;
    setState(() => epoch++);
    countdown = Timer(fingerCountdown, pick);
  }

  void pick() {
    if (!mounted || contacts.isEmpty) return;
    setState(() {
      draw = drawFingers(
        pointers: contacts.keys,
        mode: mode,
        winners: winners,
        groups: groups,
        random: random,
      );
      frozen
        ..clear()
        ..addAll(contacts);
      drawn = true;
    });
    widget.onTint?.call(tint());
    unawaited(DeviceFeedback.expired(sound: false, haptics: widget.haptics));
  }

  Color? tint() => mode == FingerMode.first && drawn && draw.winners.length == 1
      ? fingerColorAt(colors[draw.winners.first] ?? 0)
      : null;

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  void reset() {
    drawn = false;
    draw = const FingerDraw();
    frozen.clear();
    colors.removeWhere((pointer, _) => !contacts.containsKey(pointer));
    widget.onTint?.call(null);
  }

  void clearAll() {
    countdown?.cancel();
    contacts.clear();
    virtual.clear();
    reset();
  }

  void onDown(PointerDownEvent e) {
    if (e.kind == PointerDeviceKind.mouse) return click(e.localPosition);
    setState(() {
      if (contacts.isEmpty) reset();
      contacts[e.pointer] = e.localPosition;
      colors[e.pointer] = arrivals++;
    });
    unawaited(DeviceFeedback.selection(haptics: widget.haptics));
    schedule();
  }

  void click(Offset at) {
    if (drawn) return setState(clearAll);
    final near = nearestFinger(virtual, contacts, at);
    setState(() {
      if (near != null) {
        virtual.remove(near);
        contacts.remove(near);
        colors.remove(near);
      } else if (virtual.length < _maxVirtual) {
        virtual.add(seq);
        contacts[seq] = at;
        colors[seq++] = arrivals++;
      }
    });
    if (contacts.isEmpty) {
      countdown?.cancel();
    } else {
      schedule();
    }
  }

  void onMove(PointerMoveEvent e) {
    if (contacts.containsKey(e.pointer)) {
      setState(() => contacts[e.pointer] = e.localPosition);
    }
  }

  void onUp(PointerEvent e) {
    if (e.kind == PointerDeviceKind.mouse) return;
    setState(() => contacts.remove(e.pointer));
    if (!frozen.containsKey(e.pointer)) colors.remove(e.pointer);
    if (contacts.isEmpty) {
      countdown?.cancel();
    } else if (!drawn) {
      schedule();
    }
  }

  void changeMode(FingerMode value) => setState(() {
    clearAll();
    mode = value;
  });

  void options() => showFingerOptions(
    context,
    mode: mode,
    winners: winners,
    groups: groups,
    names: widget.names,
    random: random,
    onWinners: (v) => setState(() => winners = v),
    onGroups: (v) => setState(() => groups = v),
  );

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      FingerSurface(
        shown: {...frozen, ...contacts},
        colors: colors,
        draw: draw,
        mode: mode,
        drawn: drawn,
        epoch: epoch,
        background: tint() ?? fingerPadColor,
        hint: fingerHint(
          context,
          drawn: drawn,
          simulated: virtual.isNotEmpty,
          touching: contacts.isNotEmpty,
        ),
        subHint: fingerOnDesktopWeb ? context.l10n.fingerDesktopHint : null,
        onDown: onDown,
        onMove: onMove,
        onUp: onUp,
      ),
      FingerDock(
        visible: contacts.isEmpty && !drawn,
        mode: mode,
        onMode: changeMode,
        onOptions: options,
      ),
      TopBarSlot(actions: [if (fullscreenSupported) const FullscreenButton()]),
    ],
  );
}
