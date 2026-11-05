import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_inputs.dart';
import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/random_widgets.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

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
      text: context.l10n.randomRedBlueGreenRedBlue,
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
        label: context.l10n.randomCommaSeparatedOptions,
        helper: context.l10n.randomRepeatedEntriesRepresentSeveralTokens,
        onChanged: refill,
      ),
      RandomResultSlot(text: result),
      if (hasDrawn)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text('${bag.length} ${context.l10n.randomTokensRemaining}'),
        ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          RandomDrawButton(onPressed: draw),
          OutlinedButton(
            onPressed: refill,
            child: Text(context.l10n.randomRefillBag),
          ),
        ],
      ),
    ],
  );
}
