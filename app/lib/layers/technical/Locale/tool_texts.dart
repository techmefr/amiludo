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
      'stopwatch' => l.toolStopwatchTitle,
      'timer' => l.toolTimerTitle,
      'hourglass' => l.toolHourglassTitle,
      'map' => l.toolMapTitle,
      'teams' => l.toolTeamsTitle,
      'wheel' => l.toolWheelTitle,
      'coin' => l.toolCoinTitle,
      'order' => l.toolOrderTitle,
      'number' => l.toolNumberTitle,
      'bag' => l.toolBagTitle,
      'roles' => l.toolRolesTitle,
      'heroes' => l.toolHeroesTitle,
      'character' => l.toolCharacterTitle,
      'npc' => l.toolNpcTitle,
      'tavern' => l.toolTavernTitle,
      'encounter' => l.toolEncounterTitle,
      'quest' => l.toolQuestTitle,
      'treasure' => l.toolTreasureTitle,
      'villain' => l.toolVillainTitle,
      'town' => l.toolTownTitle,
      'magicitem' => l.toolMagicItemTitle,
      'weather' => l.toolWeatherTitle,
      'place' => l.toolPlaceTitle,
      'dilemma' => l.toolDilemmaTitle,
      'rumour' => l.toolRumourTitle,
      'trait' => l.toolTraitTitle,
      'twist' => l.toolTwistTitle,
      'counter-life' => l.brickLife,
      'counter-points' => l.brickPoints,
      'counter-chips' => l.brickChips,
      'counter-pot' => l.brickPot,
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
      'stopwatch' => l.toolStopwatchSubtitle,
      'timer' => l.toolTimerSubtitle,
      'hourglass' => l.toolHourglassSubtitle,
      'map' => l.toolMapSubtitle,
      'teams' => l.toolTeamsSubtitle,
      'wheel' => l.toolWheelSubtitle,
      'coin' => l.toolCoinSubtitle,
      'order' => l.toolOrderSubtitle,
      'number' => l.toolNumberSubtitle,
      'bag' => l.toolBagSubtitle,
      'roles' => l.toolRolesSubtitle,
      'heroes' => l.toolHeroesSubtitle,
      'character' => l.toolCharacterSubtitle,
      'npc' => l.toolNpcSubtitle,
      'tavern' => l.toolTavernSubtitle,
      'encounter' => l.toolEncounterSubtitle,
      'quest' => l.toolQuestSubtitle,
      'treasure' => l.toolTreasureSubtitle,
      'villain' => l.toolVillainSubtitle,
      'town' => l.toolTownSubtitle,
      'magicitem' => l.toolMagicItemSubtitle,
      'weather' => l.toolWeatherSubtitle,
      'place' => l.toolPlaceSubtitle,
      'dilemma' => l.toolDilemmaSubtitle,
      'rumour' => l.toolRumourSubtitle,
      'trait' => l.toolTraitSubtitle,
      'twist' => l.toolTwistSubtitle,
      'counter-life' => l.toolCounterLifeSubtitle,
      'counter-points' => l.toolCounterPointsSubtitle,
      'counter-chips' => l.toolCounterChipsSubtitle,
      'counter-pot' => l.toolCounterPotSubtitle,
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
      'favorites' => l.toolCategoryFavorites,
      'counters' => l.toolCategoryCounters,
      _ => l.toolCategoryAll,
    };
  }

  String toolShelfLabel(String id) {
    final l = l10n;
    return switch (id) {
      'pinned' => l.toolShelfPinned,
      'time' => l.toolShelfTime,
      'chance' => l.toolShelfChance,
      'scores' => l.toolShelfScores,
      'cards' => l.toolShelfCards,
      'map' => l.toolShelfMap,
      'story' => l.toolShelfStory,
      'generators' => l.toolShelfGenerators,
      'characters' => l.toolShelfCharacters,
      _ => l.toolShelfPlayers,
    };
  }
}
