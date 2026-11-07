import 'package:amiludo/layers/functional/Random/domain/sheet/sheet_fields.dart';
import 'package:amiludo/l10n/app_localizations.dart';

String sheetFieldLabel(AppLocalizations l, String id) => switch (id) {
  'name' => l.sheetFieldName,
  'nickname' => l.sheetFieldNickname,
  'age' => l.sheetFieldAge,
  'birthDate' => l.sheetFieldBirthDate,
  'birthPlace' => l.sheetFieldBirthPlace,
  'gender' => l.sheetFieldGender,
  'origin' => l.sheetFieldOrigin,
  'languages' => l.sheetFieldLanguages,
  'job' => l.sheetFieldJob,
  'status' => l.sheetFieldStatus,
  'group' => l.sheetFieldGroup,
  'skin' => l.sheetFieldSkin,
  'eyes' => l.sheetFieldEyes,
  'hair' => l.sheetFieldHair,
  'build' => l.sheetFieldBuild,
  'height' => l.sheetFieldHeight,
  'style' => l.sheetFieldStyle,
  'marks' => l.sheetFieldMarks,
  'qualities' => l.sheetFieldQualities,
  'flaws' => l.sheetFieldFlaws,
  'likes' => l.sheetFieldLikes,
  'dislikes' => l.sheetFieldDislikes,
  'talents' => l.sheetFieldTalents,
  'habits' => l.sheetFieldHabits,
  'motivation' => l.sheetFieldMotivation,
  'goal' => l.sheetFieldGoal,
  'family' => l.sheetFieldFamily,
  'childhood' => l.sheetFieldChildhood,
  'experiences' => l.sheetFieldExperiences,
  'evolution' => l.sheetFieldEvolution,
  'situation' => l.sheetFieldSituation,
  'aims' => l.sheetFieldAims,
  _ => id,
};

String sheetStepLabel(AppLocalizations l, int step) => switch (step) {
  1 => l.sheetStep1,
  2 => l.sheetStep2,
  3 => l.sheetStep3,
  4 => l.sheetStep4,
  _ => l.sheetStep5,
};

String sheetUniverseLabel(AppLocalizations l, String id) => switch (id) {
  'fantasy' => l.sheetUniverseFantasy,
  'scifi' => l.sheetUniverseScifi,
  'cyberpunk' => l.sheetUniverseCyberpunk,
  'gothique' => l.sheetUniverseGothique,
  _ => id,
};

Map<String, String> sheetLabelMap(AppLocalizations l) => {
  for (final f in SheetSpec.fields) f.id: sheetFieldLabel(l, f.id),
};

List<String> sheetStepNames(AppLocalizations l) => [
  for (var i = 1; i <= SheetSpec.stepCount; i++) sheetStepLabel(l, i),
];
