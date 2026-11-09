import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Library/domain/entities/library_stats.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

class LibraryStatsBar extends StatelessWidget {
  const LibraryStatsBar({
    super.key,
    required this.stats,
    required this.neverPlayedOnly,
    required this.onToggle,
  });

  final LibraryStats stats;
  final bool neverPlayedOnly;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      Chip(
        label: Text('${context.l10n.libraryStatsPlayed} · ${stats.played.length}'),
      ),
      FilterChip(
        label: Text(
          '${context.l10n.libraryStatsNever} · ${stats.neverPlayed.length}',
        ),
        selected: neverPlayedOnly,
        onSelected: onToggle,
      ),
    ],
  );
}
