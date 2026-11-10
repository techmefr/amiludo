import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Locale/tool_texts.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_tab_strip.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

const timeToolIds = [
  'timer',
  'hourglass',
  'stopwatch',
  'countdown',
  'turn-timer',
  'chess-clock',
  'phases',
  'metronome',
];

class TimeToolsShell extends StatelessWidget {
  const TimeToolsShell({super.key, required this.navigation});
  final StatefulNavigationShell navigation;

  void _select(int index) {
    if (index == navigation.currentIndex) return;
    navigation.goBranch(index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GestureDetector(
      onHorizontalDragEnd: (details) {
        final speed = details.primaryVelocity ?? 0;
        if (speed.abs() < 220) return;
        final ltr = Directionality.of(context) == TextDirection.ltr;
        final offset = (speed < 0) == ltr ? 1 : -1;
        final next = navigation.currentIndex + offset;
        if (next >= 0 && next < timeToolIds.length) _select(next);
      },
      child: navigation,
    ),
    bottomNavigationBar: Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(Space.xs),
        child: ToolTabStrip(
          tabs: ToolTabs(
            label: context.toolShelfLabel('time'),
            current: navigation.currentIndex,
            onSelect: _select,
            items: [
              for (final id in timeToolIds)
                ToolTab(
                  id: id,
                  label: context.toolTitle(id),
                  icon: toolIcon(id),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
