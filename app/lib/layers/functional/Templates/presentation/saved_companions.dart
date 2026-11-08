import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class SavedCompanions extends StatelessWidget {
  const SavedCompanions({
    super.key,
    required this.companions,
    required this.onEdit,
    required this.onPlay,
  });
  final List<GameTemplate> companions;
  final ValueChanged<GameTemplate> onEdit, onPlay;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (companions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Space.xxl),
        Semantics(
          header: true,
          child: Text(
            l.buildMine,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: Space.sm),
        for (final companion in companions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(companion.name),
            onTap: () => onEdit(companion),
            trailing: IconButton.filledTonal(
              tooltip: l.buildLaunch,
              onPressed: () => onPlay(companion),
              icon: const DeckIcon(Icons.play_arrow),
            ),
          ),
      ],
    );
  }
}
