import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
          null => context.l10n.randomPressTheButtonToRoll,
          true => context.l10n.randomHeads,
          false => context.l10n.randomTails,
        },
      ),
      RandomDrawButton(
        onPressed: () => setState(() => heads = random.integer(0, 1) == 1),
      ),
    ],
  );
}
