import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/playing_card.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_focus.dart';

List<String> challengeLines(String text) => [
  for (final line in text.split('\n'))
    if (line.trim().isNotEmpty) line.trim(),
];

class ChallengesTool extends StatefulWidget {
  const ChallengesTool({super.key, this.random});
  final Random? random;

  @override
  State<ChallengesTool> createState() => _ChallengesToolState();
}

class _ChallengesToolState extends State<ChallengesTool> {
  final tool = toolThemeFor('challenges');
  late final Random _random = widget.random ?? Random.secure();
  TextEditingController? _lines;
  String? current;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lines ??= TextEditingController(
      text: context.l10n.challengeStarters.split('|').join('\n'),
    );
  }

  @override
  void dispose() {
    _lines?.dispose();
    super.dispose();
  }

  void _draw() {
    final pool = challengeLines(_lines!.text);
    if (pool.isEmpty) return;
    tool.signal();
    final others = pool.length > 1 ? pool.where((c) => c != current) : pool;
    final choices = others.toList();
    setState(() => current = choices[_random.nextInt(choices.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final width = (MediaQuery.sizeOf(context).width * .6).clamp(180.0, 260.0);
    return Align(
      alignment: Alignment.topCenter,
      child: ToolFocus(
        baseWidth: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: tool.duration(context),
                child: Semantics(
                  key: ValueKey(current),
                  liveRegion: true,
                  label: current ?? l.challengeFaceDown,
                  excludeSemantics: true,
                  child: current == null
                      ? PlayingCard(faceDown: true, width: width)
                      : PlayingCard(label: current, width: width),
                ),
              ),
            ),
            const SizedBox(height: Space.xl),
            ToolPrimaryButton(
              onPressed: _draw,
              icon: Icons.style_outlined,
              label: l.challengeDraw,
            ),
            const SizedBox(height: Space.xl),
            TextField(
              controller: _lines,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: l.challengeEdit,
                helperText: l.challengeEditHelper,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
