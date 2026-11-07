import 'package:flutter/widgets.dart';

import 'package:amiludo/l10n/app_localizations.dart';
import 'package:amiludo/layers/functional/Notebook/domain/entities/oracle.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';

Future<OracleTables> loadOracleTables(
  AssetBundle bundle,
  String language,
) async {
  try {
    return OracleTables.decode(
      await bundle.loadString('assets/oracle/$language.json'),
    );
  } on FlutterError {
    return OracleTables.decode(
      await bundle.loadString('assets/oracle/en.json'),
    );
  }
}

extension OracleTexts on BuildContext {
  String likelihoodLabel(Likelihood likelihood) => switch (likelihood) {
    Likelihood.veryUnlikely => l10n.notebookLikelihoodVeryUnlikely,
    Likelihood.unlikely => l10n.notebookLikelihoodUnlikely,
    Likelihood.even => l10n.notebookLikelihoodEven,
    Likelihood.likely => l10n.notebookLikelihoodLikely,
    Likelihood.veryLikely => l10n.notebookLikelihoodVeryLikely,
  };

  String answerText(Likelihood likelihood, OracleAnswer answer) {
    final AppLocalizations l = l10n;
    final verdict = switch ((answer.yes, answer.exceptional)) {
      (true, true) => l.notebookAnswerExceptionalYes,
      (true, false) => l.notebookAnswerYes,
      (false, true) => l.notebookAnswerExceptionalNo,
      (false, false) => l.notebookAnswerNo,
    };
    final event = answer.event ? ' · ${l.notebookAnswerEvent}' : '';
    return '${likelihoodLabel(likelihood)}: $verdict '
        '(${answer.roll}/${answer.chance})$event';
  }

  String sceneText(SceneOutcome outcome) => switch (outcome) {
    SceneOutcome.expected => l10n.notebookSceneExpected,
    SceneOutcome.altered => l10n.notebookSceneAltered,
    SceneOutcome.interrupted => l10n.notebookSceneInterrupted,
  };
}
