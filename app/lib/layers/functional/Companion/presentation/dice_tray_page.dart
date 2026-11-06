import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_controls.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_summary.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_surface.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Motion/shake_source.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class DiceTrayPage extends StatefulWidget {
  const DiceTrayPage({
    super.key,
    this.initial = const DiceTraySettings(),
    this.shakeSource = const NoShakeSource(),
    this.seed,
    this.onChanged,
  });
  final DiceTraySettings initial;
  final ShakeSource shakeSource;
  final int? seed;
  final ValueChanged<DiceTraySettings>? onChanged;

  @override
  State<DiceTrayPage> createState() => _DiceTrayPageState();
}

class _DiceTrayPageState extends State<DiceTrayPage> {
  late DiceTraySession session = DiceTraySession(settings: widget.initial);
  late final int seed = widget.seed ?? DateTime.now().microsecondsSinceEpoch;
  StreamSubscription<void>? shakes;
  int throwId = 0;

  @override
  void initState() {
    super.initState();
    shakes = widget.shakeSource.shakes.listen((_) => throwDice());
  }

  @override
  void dispose() {
    shakes?.cancel();
    super.dispose();
  }

  void throwDice() {
    if (session.settings.dice.isEmpty) return;
    setState(() {
      throwId++;
      session = session.throwDice(SeededRandom(seed + throwId));
    });
  }

  void configure(DiceTraySettings next) {
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
