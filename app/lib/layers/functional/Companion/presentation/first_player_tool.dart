import 'dart:math';

import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/first_player.dart';
import 'package:amiludo/layers/functional/Companion/presentation/first_player_ring.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const _spinTime = Duration(milliseconds: 2800);

class FirstPlayerTool extends StatefulWidget {
  const FirstPlayerTool({super.key, required this.names, this.random});
  final List<String> names;
  final Random? random;

  @override
  State<FirstPlayerTool> createState() => _FirstPlayerToolState();
}

class _FirstPlayerToolState extends State<FirstPlayerTool>
    with SingleTickerProviderStateMixin {
  late final AnimationController spin = AnimationController(
    vsync: this,
    duration: _spinTime,
  );
  late final Random random = widget.random ?? Random();
  final tool = toolThemeFor('first-player');
  List<int> sequence = const [0];
  int resting = 0;
  int? chosen;
  bool drawing = false;

  @override
  void dispose() {
    spin.dispose();
    super.dispose();
  }

  Future<void> _draw() async {
    final count = widget.names.length;
    final target = drawFirstPlayer(count, random);
    final reduce = MediaQuery.disableAnimationsOf(context);
    tool.signal();
    setState(() {
      chosen = null;
      drawing = true;
      sequence = spinSequence(count, target, start: resting);
    });
    if (reduce) {
      spin.value = 1;
    } else {
      await spin.forward(from: 0);
    }
    if (!mounted) return;
    tool.signal();
    setState(() {
      resting = target;
      chosen = target;
      drawing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: spin,
                builder: (context, _) {
                  final at = spinAt(
                    sequence,
                    Curves.easeOutCubic.transform(spin.value),
                  );
                  return FirstPlayerRing(
                    names: widget.names,
                    from: at.from,
                    to: at.to,
                    fraction: at.fraction,
                    chosen: chosen,
                  );
                },
              ),
              const SizedBox(height: Space.lg),
              Semantics(
                liveRegion: true,
                child: Text(
                  chosen == null ? '' : l.firstPlayerStarts(widget.names[chosen!]),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: Space.lg),
              FilledButton.icon(
                onPressed: drawing ? null : _draw,
                icon: const DeckIcon(Icons.casino_outlined),
                label: Text(
                  chosen == null ? l.firstPlayerDraw : l.firstPlayerAgain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
