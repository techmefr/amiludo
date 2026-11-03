import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';

class BagTool extends StatefulWidget {
  const BagTool({super.key});
  @override
  State<BagTool> createState() => _BagToolState();
}

class _BagToolState extends State<BagTool> {
  final random = RandomTools();
  TextEditingController? options;
  List<String> bag = [];
  bool hasDrawn = false;
  String result = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    options ??= TextEditingController(
      text: tr(
        context,
        'Rouge, Bleu, Vert, Rouge, Bleu',
        'Red, Blue, Green, Red, Blue',
      ),
    );
  }

  @override
  void dispose() {
    options?.dispose();
    super.dispose();
  }

  void draw() {
    try {
      if (!hasDrawn) {
        bag = random.shuffled(parseBag(options!.text));
        hasDrawn = true;
      }
      if (bag.isEmpty) throw RandomInputError.emptyBag;
      setState(() => result = bag.removeLast());
    } on RandomInputError catch (error) {
      notify(context, randomInputErrorText(context, error));
    }
  }

  void refill() => setState(() {
    bag = [];
    hasDrawn = false;
    result = '';
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RandomOptionsField(
        controller: options!,
        label: tr(
          context,
          'Options séparées par des virgules',
          'Comma-separated options',
        ),
        helper: tr(
          context,
          'Les répétitions représentent plusieurs jetons.',
          'Repeated entries represent several tokens.',
        ),
        onChanged: refill,
      ),
      RandomResultSlot(text: result),
      if (hasDrawn)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            '${bag.length} ${tr(context, 'jetons restants', 'tokens remaining')}',
          ),
        ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          RandomDrawButton(onPressed: draw),
          OutlinedButton(
            onPressed: refill,
            child: Text(tr(context, 'Remplir le sac', 'Refill bag')),
          ),
        ],
      ),
    ],
  );
}
