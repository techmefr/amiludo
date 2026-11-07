import package:flutter/material.dart;

import package:amiludo/layers/technical/Locale/context_l10n.dart;
import package:amiludo/layers/technical/Theme/tokens/design_tokens.dart;

class FingerNamePicker extends StatelessWidget {
  const FingerNamePicker({
    super.key,
    required this.names,
    required this.chosen,
    required this.onPick,
  });

  final List<String> names;
  final String? chosen;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: Space.xl),
      Text(context.l10n.randomOrPickANameWithout),
      const SizedBox(height: Space.lg),
      FilledButton(
        onPressed: names.isEmpty ? null : onPick,
        child: Text(context.l10n.randomPickAPlayer),
      ),
      if (chosen != null)
        Padding(
          padding: const EdgeInsets.only(top: Space.xl),
          child: Semantics(
            liveRegion: true,
            child: Text(
              chosen!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
    ],
  );
}
