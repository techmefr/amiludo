import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

extension ToolTexts on BuildContext {
  String toolTitle(String id) {
    final l = l10n;
    return switch (id) {
      'picker' => l.toolPickerTitle,
      'dice' => l.toolDiceTitle,
      'scores' => l.toolScoresTitle,
      'timer' => l.toolTimerTitle,
      'teams' => l.toolTeamsTitle,
      'wheel' => l.toolWheelTitle,
      'coin' => l.toolCoinTitle,
      'order' => l.toolOrderTitle,
      'number' => l.toolNumberTitle,
      'bag' => l.toolBagTitle,
      'roles' => l.toolRolesTitle,
      'character' => l.toolCharacterTitle,
      'npc' => l.toolNpcTitle,
      'tavern' => l.toolTavernTitle,
      'encounter' => l.toolEncounterTitle,
      _ => id,
    };
  }

  String toolSubtitle(String id) {
    final l = l10n;
    return switch (id) {
      'picker' => l.toolPickerSubtitle,
      'dice' => l.toolDiceSubtitle,
      'scores' => l.toolScoresSubtitle,
      'timer' => l.toolTimerSubtitle,
      'teams' => l.toolTeamsSubtitle,
      'wheel' => l.toolWheelSubtitle,
      'coin' => l.toolCoinSubtitle,
      'order' => l.toolOrderSubtitle,
      'number' => l.toolNumberSubtitle,
      'bag' => l.toolBagSubtitle,
      'roles' => l.toolRolesSubtitle,
      'character' => l.toolCharacterSubtitle,
      'npc' => l.toolNpcSubtitle,
      'tavern' => l.toolTavernSubtitle,
      'encounter' => l.toolEncounterSubtitle,
      _ => '',
    };
  }

  String toolCategoryLabel(String id) {
    final l = l10n;
    return switch (id) {
      'chance' => l.toolCategoryChance,
      'match' => l.toolCategoryMatch,
      'time' => l.toolCategoryTime,
      'story' => l.toolCategoryStory,
      _ => l.toolCategoryAll,
    };
  }
}
