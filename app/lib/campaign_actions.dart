import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/counter.dart';
import 'package:amiludo/layers/functional/Companion/presentation/counter_view.dart';
import 'package:amiludo/layers/functional/Companion/presentation/dice_tray_page.dart';
import 'package:amiludo/layers/functional/Companion/presentation/heroes_tool.dart';
import 'package:amiludo/layers/functional/Companion/presentation/hourglass_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/generator_tool.dart';

const _lifeSettings = CounterSettings(
  start: 5,
  minimum: 0,
  maximum: 5,
  color: 0xFFC8423F,
  icon: 'heart',
  display: CounterDisplay.hearts,
);

class _LifeCounter extends StatefulWidget {
  const _LifeCounter();

  @override
  State<_LifeCounter> createState() => _LifeCounterState();
}

class _LifeCounterState extends State<_LifeCounter> {
  final state = CounterState(_lifeSettings);

  @override
  Widget build(BuildContext context) => CounterView(state: state);
}

final campaignActions = <MissionAction, WidgetBuilder>{
  MissionAction.dice: (context) => const DiceTrayPage(),
  MissionAction.life: (context) => const _LifeCounter(),
  MissionAction.sheet: (context) => const HeroesTool(),
  MissionAction.generator: (context) => const GeneratorTool(id: 'dilemma'),
  MissionAction.hourglass: (context) => const HourglassTool(),
};
