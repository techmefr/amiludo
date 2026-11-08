import 'package:amiludo/l10n/app_localizations.dart';

String sheetPresetLabel(AppLocalizations l, String id) => switch (id) {
  'catan' => l.sheetPresetCatan,
  'skyjo' => l.sheetPresetSkyjo,
  _ => l.sheetPresetYams,
};

String sheetRowLabel(AppLocalizations l, String id) => switch (id) {
  'ones' => l.sheetRowOnes,
  'twos' => l.sheetRowTwos,
  'threes' => l.sheetRowThrees,
  'fours' => l.sheetRowFours,
  'fives' => l.sheetRowFives,
  'sixes' => l.sheetRowSixes,
  'three-kind' => l.sheetRowThreeKind,
  'four-kind' => l.sheetRowFourKind,
  'full-house' => l.sheetRowFullHouse,
  'small-straight' => l.sheetRowSmallStraight,
  'large-straight' => l.sheetRowLargeStraight,
  'yams' => l.sheetRowYams,
  'chance' => l.sheetRowChance,
  'settlements' => l.sheetRowSettlements,
  'cities' => l.sheetRowCities,
  'longest-road' => l.sheetRowLongestRoad,
  'largest-army' => l.sheetRowLargestArmy,
  'victory-cards' => l.sheetRowVictoryCards,
  _ => id,
};
