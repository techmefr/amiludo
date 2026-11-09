import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class NumberTool extends StatefulWidget {
  const NumberTool({super.key});
  @override
  State<NumberTool> createState() => _NumberToolState();
}

class _NumberToolState extends State<NumberTool> {
  final random = RandomTools();
  final minimum = TextEditingController(text: '1'),
      maximum = TextEditingController(text: '100');
  String result = '';

  @override
  void dispose() {
    minimum.dispose();
    maximum.dispose();
    super.dispose();
  }

  void draw() {
    try {
      final bounds = NumberBounds.parse(minimum.text, maximum.text);
      setState(
        () => result = '${random.integer(bounds.minimum, bounds.maximum)}',
      );
    } on RandomInputError catch (error) {
      notify(context, randomInputErrorText(context, error));
    }
  }

  Widget boundField(TextEditingController controller, String label) => Expanded(
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      decoration: InputDecoration(labelText: label),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        spacing: Space.lg,
        children: [
          boundField(minimum, context.l10n.randomMinimum),
          boundField(maximum, context.l10n.randomMaximum),
        ],
      ),
      RandomResultSlot(text: result),
      RandomDrawButton(onPressed: draw),
    ],
  );
}
