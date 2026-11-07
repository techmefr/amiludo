import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/dice_tray.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/tray_result.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_2d_panel.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_3d_panel.dart';
import 'package:amiludo/layers/functional/Companion/presentation/tray_stage.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_actions_sheet.dart';
import 'package:amiludo/layers/functional/Companion/presentation/die_studio.dart';
import 'package:amiludo/layers/technical/Dice3D/die_skin.dart';
import 'package:amiludo/layers/technical/Dice3D/table_theme.dart';
import 'package:amiludo/layers/technical/Feedback/tray_feedback.dart';
import 'package:amiludo/layers/technical/Motion/shake_source.dart';
import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Sensors/tray_motion.dart';
import 'package:amiludo/layers/technical/Sound/sound_output.dart';

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
    this.solid = false,
    this.onSolidChanged,
    this.skin = 'classic',
    this.table = 'felt',
    this.onSkinChanged,
    this.onTableChanged,
  });
  final DiceTraySettings initial;
  final ShakeSource shakeSource;
  final int? seed;
  final ValueChanged<DiceTraySettings>? onChanged;
  final TrayMotion motion;
  final SoundOutput soundOutput;
  final bool sound, haptics, solid;
  final String skin, table;
  final ValueChanged<bool>? onSolidChanged;
  final ValueChanged<String>? onSkinChanged, onTableChanged;

  @override
  State<DiceTrayPage> createState() => _DiceTrayPageState();
}

class _DiceTrayPageState extends State<DiceTrayPage> {
  late DiceTraySession session = DiceTraySession(
    settings: _live(widget.initial),
  );

  DiceTraySettings _live(DiceTraySettings settings) {
    final library = DieStudio.maybeOf(context)?.state;
    return library == null ? settings : settings.resolved(library);
  }

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
  late bool solid = widget.solid;
  late String skin = widget.skin, table = widget.table;
  double power = 0.7;
  Offset aim = Offset.zero;
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

  void throwDice([double strength = 0.7, Offset direction = Offset.zero]) {
    if (session.settings.dice.isEmpty) return;
    setState(() {
      power = strength;
      aim = direction;
      throwId++;
      session = session.throwDice(SeededRandom(seed + throwId));
    });
  }

  void configure(DiceTraySettings next) {
    final kept = session.settings.withDice(next.dice);
    setState(() => session = session.withSettings(kept));
    widget.onChanged?.call(kept);
  }

  void toggleFavorite(String key) {
    final next = session.settings.toggleFavorite(key);
    setState(() => session = session.withPreferences(next));
    widget.onChanged?.call(next);
  }

  void editDie(int index) => showDieActionsSheet(
    context,
    session.settings.dice[index],
    onRemove: () => configure(
      session.settings.withDice([...session.settings.dice]..removeAt(index)),
    ),
  );

  void chooseSurface(String name) {
    final next = session.settings.withSurface(name);
    setState(() => session = session.withSettings(next));
    widget.onChanged?.call(next);
  }

  void chooseMode(TrayResultMode mode) {
    setState(() => session = session.withMode(mode.name));
    widget.onChanged?.call(session.settings);
  }

  void changeView(bool value) {
    setState(() => solid = value);
    widget.onSolidChanged?.call(value);
  }

  Widget stage() => TrayStage(
    session: session,
    throwId: throwId,
    seed: seed,
    power: power,
    aim: aim,
    onFlick: throwDice,
    onTapTable: throwDice,
    onLongPressDie: editDie,
    tilt: tilt,
    feedback: feedback,
    solid: solid,
    skin: DieSkin.byId(skin),
    table: TableTheme.byId(table),
    onOutcome: (v) => setState(() => session = session.withOutcome(v)),
    onTapDie: (i) =>
        solid ? throwDice() : setState(() => session = session.toggleKeep(i)),
    onView: changeView,
  );

  @override
  Widget build(BuildContext context) {
    if (solid) {
      return Dice3dPanel(
        session: session,
        stage: stage(),
        skin: skin,
        table: table,
        onConfigure: configure,
        onThrow: throwDice,
        mode: TrayResultMode.parse(session.settings.resultMode),
        onMode: chooseMode,
        onClear: () => setState(() => session = session.cleared()),
        onFavorite: toggleFavorite,
        onSkin: (id) {
          setState(() => skin = id);
          widget.onSkinChanged?.call(id);
        },
        onTable: (id) {
          setState(() => table = id);
          widget.onTableChanged?.call(id);
        },
      );
    }
    return Dice2dPanel(
      session: session,
      stage: stage(),
      onConfigure: configure,
      onSurface: chooseSurface,
      onThrow: throwDice,
      onKeep: (i) => setState(() => session = session.toggleKeep(i)),
    );
  }
}
