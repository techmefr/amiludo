import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

enum FingerMode { first, rank }

class FingerModeSelector extends StatelessWidget {
  const FingerModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final FingerMode mode;
  final ValueChanged<FingerMode> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<FingerMode>(
    segments: [
      ButtonSegment(
        value: FingerMode.first,
        label: Text(context.l10n.randomModeFirst),
      ),
      ButtonSegment(
        value: FingerMode.rank,
        label: Text(context.l10n.randomModeRank),
      ),
    ],
    selected: {mode},
    onSelectionChanged: (v) => onChanged(v.first),
  );
}
