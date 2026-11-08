import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/cubit/templates_cubit.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_grid.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_stage.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_tile.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

export 'package:amiludo/layers/functional/Templates/presentation/session_tile.dart'
    show BrickWidgetBuilder;

class CompanionSession extends StatefulWidget {
  const CompanionSession({super.key, required this.id, required this.builder});
  final String id;
  final BrickWidgetBuilder builder;

  @override
  State<CompanionSession> createState() => _CompanionSessionState();
}

class _CompanionSessionState extends State<CompanionSession> {
  bool arrange = false;
  int? focused;

  int _resume(List<Brick> bricks) {
    final last = lastSessionTool(widget.id);
    final index = bricks.indexWhere((b) => b.id == last);
    return index < 0 ? 0 : index;
  }

  Future<void> _move(GameTemplate template, int from, int to) {
    final next = [...template.bricks];
    next.insert(to, next.removeAt(from));
    return context.read<TemplatesCubit>().addTemplate(
      template.withBricks(next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final template = context
        .watch<TemplatesCubit>()
        .state
        .templates
        .where((t) => t.id == widget.id)
        .firstOrNull;
    if (template == null) {
      return FullPage(
        title: l.templatesPackNotFound,
        fallback: '/',
        child: Text(l.templatesThisPackIsNoLonger),
      );
    }
    final bricks = template.bricks;
    if (focused != null && bricks.isNotEmpty) {
      return SessionStage(
        key: ValueKey(widget.id),
        sessionId: widget.id,
        title: template.name,
        bricks: bricks,
        builder: widget.builder,
        initial: focused!,
        onGrid: () => setState(() => focused = null),
      );
    }
    return FullPage(
      title: template.name,
      fallback: '/',
      immersive: true,
      maxWidth: 1400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: template.bricks.isEmpty
                      ? null
                      : () => setState(
                          () => focused = _resume(template.bricks),
                        ),
                  icon: const DeckIcon(Icons.open_in_full),
                  label: Text(l.sessionFullscreen),
                ),
                AnimatedSwitcher(
              duration: Motion.of(context, Motion.fast),
              child: TextButton.icon(
                key: ValueKey(arrange),
                onPressed: () => setState(() => arrange = !arrange),
                icon: DeckIcon(arrange ? Icons.check : Icons.swap_vert),
                label: Text(arrange ? l.buildArrangeDone : l.buildArrange),
              ),
            ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          SessionGrid(
            bricks: template.bricks,
            builder: widget.builder,
            arrange: arrange,
            onMove: (from, to) => _move(template, from, to),
            onOpen: (index) => setState(() => focused = index),
          ),
        ],
      ),
    );
  }
}
