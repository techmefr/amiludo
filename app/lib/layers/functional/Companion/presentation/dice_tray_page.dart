import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_controls.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_summary.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_arena.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_surface_picker.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Motion/shake_source.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Physics/surface_material.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DiceTrayPage extends StatefulWidget {
  const DiceTrayPage({
    super.key,
    this.initial = const DiceTraySettings(),
    this.shakeSource = const NoShakeSource(),
    this.seed,
    this.onChanged,
    this.motion = const NoTrayMotion(),
    this.soundOutput = const SilentSoundOutput(),
    this.sound = false,
    this.haptics = false,
  });
  final DiceTraySettings initial;
  final ShakeSource shakeSource;
  final int? seed;
  final ValueChanged<DiceTraySettings>? onChanged;
  final TrayMotion motion;
  final SoundOutput soundOutput;
  final bool sound, haptics;

  @override
  State<DiceTrayPage> createState() => _DiceTrayPageState();
}

class _DiceTrayPageState extends State<DiceTrayPage> {
  late DiceTraySession session = DiceTraySession(settings: widget.initial);
  late final int seed = widget.seed ?? DateTime.now().microsecondsSinceEpoch;
  late final TrayFeedback feedback = TrayFeedback(
    output: widget.soundOutput,
    sound: widget.sound,
    haptics: widget.haptics,
  );
  StreamSubscription<void>? shakes;
  StreamSubscription<double>? throws;
  StreamSubscription<Tilt>? tilts;
  int throwId = 0;
  double power = 0.7;
  Tilt tilt = Tilt.flat;

  @override
  void initState() {
    super.initState();
    shakes = widget.shakeSource.shakes.listen((_) => throwDice());
    throws = widget.motion.throws.listen(throwDice);
    tilts = widget.motion.tilts.listen((t) {
      if ((t.x - tilt.x).abs() + (t.y - tilt.y).abs() > 0.03) {
        setState(() => tilt = t);
      }
    });
  }

  @override
  void dispose() {
    shakes?.cancel();
    throws?.cancel();
    tilts?.cancel();
    super.dispose();
  }

  void throwDice([double strength = 0.7]) {
    if (session.settings.dice.isEmpty) return;
    setState(() {
      power = strength;
      throwId++;
      session = session.throwDice(SeededRandom(seed + throwId));
    });
  }

  void configure(DiceTraySettings next) {
    final kept = DiceTraySettings(
      dice: next.dice,
      surface: session.settings.surface,
    );
    setState(() => session = session.withSettings(kept));
    widget.onChanged?.call(kept);
  }

  void chooseSurface(String name) {
    final next = session.settings.withSurface(name);
    setState(() => session = session.withSettings(next));
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final trayHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      240.0,
      520.0,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DiceTrayControls(settings: session.settings, onChanged: configure),
        const SizedBox(height: Space.md),
        TraySurfacePicker(
          value: SurfaceMaterial.parse(session.settings.surface).name,
          onChanged: chooseSurface,
        ),
        const SizedBox(height: Space.lg),
        Text(
          session.settings.dice.isEmpty
              ? l.diceTrayEmpty
              : '${l.diceTrayShakeHint} ${l.diceTrayKeepHint}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: Space.md),
        SizedBox(
          height: trayHeight,
          child: DiceTraySurface(
            session: session,
            throwId: throwId,
            seed: seed,
            power: power,
            tilt: tilt,
            feedback: feedback,
            onOutcome: (v) => setState(() => session = session.withOutcome(v)),
            onTapDie: (i) => setState(() => session = session.toggleKeep(i)),
          ),
        ),
        const SizedBox(height: Space.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: session.settings.dice.isEmpty ? null : throwDice,
            icon: const DeckIcon(Icons.casino_outlined),
            label: Text(l.diceTrayThrow),
          ),
        ),
        const SizedBox(height: Space.md),
        DiceTraySummary(
          session: session,
          onTapDie: (i) => setState(() => session = session.toggleKeep(i)),
        ),
      ],
    );
  }
}
