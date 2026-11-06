import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/presentation/bag_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/coin_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/generator_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/number_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/order_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/roles_tool.dart';
import 'package:amiludo/layers/functional/Random/presentation/wheel_tool.dart';

class RandomTool extends StatelessWidget {
  const RandomTool({super.key, required this.id, required this.names});
  final String id;
  final List<String> names;
  @override
  Widget build(BuildContext context) => switch (id) {
    'order' => OrderTool(names: names),
    'coin' => const CoinTool(),
    'number' => const NumberTool(),
    'bag' => const BagTool(),
    'roles' => RolesTool(names: names),
    'wheel' => WheelTool(names: names),
    'npc' ||
    'tavern' ||
    'encounter' ||
    'quest' ||
    'treasure' ||
    'villain' ||
    'town' => GeneratorTool(id: id),
    _ => const SizedBox.shrink(),
  };
}
