import 'package:amiludo/l10n/app_localizations.dart';

class MissionTexts {
  const MissionTexts(this.title, this.story, this.lesson, this.task, this.badge);

  final String title, story, lesson, task, badge;
}

class MissionChoice {
  const MissionChoice(this.label, this.outcome);

  final String label, outcome;
}

MissionTexts missionTexts(AppLocalizations l, String id) => switch (id) {
  'first-roll' => MissionTexts(
    l.campaignM1Title,
    l.campaignM1Story,
    l.campaignM1Lesson,
    l.campaignM1Task,
    l.campaignM1Badge,
  ),
  'life-points' => MissionTexts(
    l.campaignM2Title,
    l.campaignM2Story,
    l.campaignM2Lesson,
    l.campaignM2Task,
    l.campaignM2Badge,
  ),
  'hero-sheet' => MissionTexts(
    l.campaignM3Title,
    l.campaignM3Story,
    l.campaignM3Lesson,
    l.campaignM3Task,
    l.campaignM3Badge,
  ),
  'first-fight' => MissionTexts(
    l.campaignM4Title,
    l.campaignM4Story,
    l.campaignM4Lesson,
    l.campaignM4Task,
    l.campaignM4Badge,
  ),
  'crossroads' => MissionTexts(
    l.campaignM5Title,
    l.campaignM5Story,
    l.campaignM5Lesson,
    l.campaignM5Task,
    l.campaignM5Badge,
  ),
  _ => MissionTexts(
    l.campaignM6Title,
    l.campaignM6Story,
    l.campaignM6Lesson,
    l.campaignM6Task,
    l.campaignM6Badge,
  ),
};

List<MissionChoice> missionChoices(AppLocalizations l) => [
  MissionChoice(l.campaignM5ChoiceA, l.campaignM5OutcomeA),
  MissionChoice(l.campaignM5ChoiceB, l.campaignM5OutcomeB),
];
