import 'package:flutter/widgets.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

extension ToolTexts on BuildContext {
  String toolTitle(String id) {
    final l = l10n;
    return switch (id) {
      'picker' => l.toolPickerTitle,
      'dice' => l.toolDiceTitle,
      'dice-tray' => l.toolDiceTrayTitle,
      'scores' => l.toolScoresTitle,
      'timer' => l.toolTimerTitle,
      'hourglass' => l.toolHourglassTitle,
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
      'quest' => l.toolQuestTitle,
      'treasure' => l.toolTreasureTitle,
      'villain' => l.toolVillainTitle,
      'town' => l.toolTownTitle,
      _ => id,
    };
  }

  String toolSubtitle(String id) {
    final l = l10n;
    return switch (id) {
      'picker' => l.toolPickerSubtitle,
      'dice' => l.toolDiceSubtitle,
      'dice-tray' => l.toolDiceTraySubtitle,
      'scores' => l.toolScoresSubtitle,
      'timer' => l.toolTimerSubtitle,
      'hourglass' => l.toolHourglassSubtitle,
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
      'quest' => l.toolQuestSubtitle,
      'treasure' => l.toolTreasureSubtitle,
      'villain' => l.toolVillainSubtitle,
      'town' => l.toolTownSubtitle,
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
