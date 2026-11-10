import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

enum FingerMode { first, rank, groups }

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
    showSelectedIcon: false,
    segments: [
      ButtonSegment(
        value: FingerMode.first,
        label: Text(context.l10n.randomModeFirst),
      ),
      ButtonSegment(
        value: FingerMode.rank,
        label: Text(context.l10n.randomModeRank),
      ),
      ButtonSegment(
        value: FingerMode.groups,
        label: Text(context.l10n.fingerModeGroups),
      ),
    ],
    selected: {mode},
    onSelectionChanged: (v) => onChanged(v.first),
  );
}
