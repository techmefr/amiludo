import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Random/domain/entities/random_tools.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_mode_selector.dart';
import 'package:amiludo/layers/functional/Random/presentation/finger_options.dart';

Future<void> showFingerOptions(
  BuildContext context, {
  required FingerMode mode,
  required int winners,
  required int groups,
  required ValueChanged<int> onWinners,
  required ValueChanged<int> onGroups,
  required List<String> names,
  required RandomTools random,
}) {
  var shownWinners = winners, shownGroups = groups;
  String? chosen;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => StatefulBuilder(
      builder: (_, refresh) => FingerOptions(
        mode: mode,
        winners: shownWinners,
        groups: shownGroups,
        names: names,
        chosen: chosen,
        onWinners: (v) {
          onWinners(v);
          refresh(() => shownWinners = v);
        },
        onGroups: (v) {
          onGroups(v);
          refresh(() => shownGroups = v);
        },
        onPick: () =>
            refresh(() => chosen = names[random.integer(0, names.length - 1)]),
      ),
    ),
  );
}
