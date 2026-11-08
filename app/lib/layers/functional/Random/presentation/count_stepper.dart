import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.lessTooltip,
    required this.moreTooltip,
    required this.onChanged,
  });
  final String label, lessTooltip, moreTooltip;
  final int value, minimum, maximum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(label, style: text.titleMedium)),
        IconButton(
          tooltip: lessTooltip,
          onPressed: value > minimum ? () => onChanged(value - 1) : null,
          icon: const DeckIcon(Icons.remove),
        ),
        Semantics(
          liveRegion: true,
          child: SizedBox(
            width: Space.xxl,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: text.titleLarge,
            ),
          ),
        ),
        IconButton(
          tooltip: moreTooltip,
          onPressed: value < maximum ? () => onChanged(value + 1) : null,
          icon: const DeckIcon(Icons.add),
        ),
      ],
    );
  }
}
