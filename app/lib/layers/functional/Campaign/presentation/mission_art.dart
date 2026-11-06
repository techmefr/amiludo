import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Campaign/domain/entities/campaign_catalog.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

IconData missionIcon(String id) => switch (id) {
  'first-roll' => Icons.casino_outlined,
  'life-points' => Icons.favorite_border,
  'hero-sheet' => Icons.badge_outlined,
  'first-fight' => Icons.shield_outlined,
  'crossroads' => Icons.call_split,
  _ => Icons.timer_outlined,
};

IconData missionBadgeIcon(String id) => switch (id) {
  'first-roll' => Icons.key_outlined,
  'life-points' => Icons.favorite,
  'hero-sheet' => Icons.star,
  'first-fight' => Icons.shield,
  'crossroads' => Icons.explore_outlined,
  _ => Icons.local_fire_department_outlined,
};

class MissionArt extends StatelessWidget {
  const MissionArt({super.key, required this.mission, this.height = 56});

  final Mission mission;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: height,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.tertiary],
          ),
        ),
        child: DeckIcon(
          missionIcon(mission.id),
          size: height / 2,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}
