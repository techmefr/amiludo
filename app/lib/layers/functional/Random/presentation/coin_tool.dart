import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';

class CoinTool extends StatefulWidget {
  const CoinTool({super.key});
  @override
  State<CoinTool> createState() => _CoinToolState();
}

class _CoinToolState extends State<CoinTool> {
  final random = RandomTools();
  bool? heads;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RandomResultSlot(
        text: switch (heads) {
          null => '',
          true => tr(context, 'FACE', 'HEADS'),
          false => tr(context, 'PILE', 'TAILS'),
        },
      ),
      RandomDrawButton(
        onPressed: () => setState(() => heads = random.integer(0, 1) == 1),
      ),
    ],
  );
}
