import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class OrderTool extends StatefulWidget {
  const OrderTool({super.key, required this.names});
  final List<String> names;
  @override
  State<OrderTool> createState() => _OrderToolState();
}

class _OrderToolState extends State<OrderTool> {
  final random = RandomTools();
  String result = '';

  void draw() => setState(
    () => result = random
        .shuffled(widget.names)
        .indexed
        .map((e) => '${e.$1 + 1}. ${e.$2}')
        .join('\n'),
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RandomResultSlot(text: result, compact: true),
      RandomDrawButton(onPressed: draw),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          '${context.l10n.randomParticipants} : ${widget.names.join(' · ')}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}
