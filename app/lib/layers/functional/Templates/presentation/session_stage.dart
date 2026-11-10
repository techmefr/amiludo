import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/functional/Companion/domain/entities/brick_layout.dart';
import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';
import 'package:amiludo/layers/functional/Templates/presentation/companion_brick_row.dart';
import 'package:amiludo/layers/functional/Templates/presentation/session_tile.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_switcher.dart';
import 'package:amiludo/layers/technical/Theme/deck_icons.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

final Map<String, String> _lastTool = {};

String? lastSessionTool(String sessionId) => _lastTool[sessionId];

class SessionStage extends StatefulWidget {
  const SessionStage({
    super.key,
    required this.sessionId,
    required this.title,
    required this.bricks,
    required this.builder,
    required this.initial,
    required this.onGrid,
  });
  final String sessionId, title;
  final List<Brick> bricks;
  final BrickWidgetBuilder builder;
  final int initial;
  final VoidCallback onGrid;

  @override
  State<SessionStage> createState() => _SessionStageState();
}

class _SessionStageState extends State<SessionStage> {
  static const double _edge = Space.xl;
  static const double _flick = 300;
  late int current = widget.initial.clamp(0, widget.bricks.length - 1);
  late final Set<String> visited = {widget.bricks[current].id};

  void _select(int index) {
    final count = widget.bricks.length;
    final next = ((index % count) + count) % count;
    final brick = widget.bricks[next];
    _lastTool[widget.sessionId] = brick.id;
    setState(() {
      current = next;
      visited.add(brick.id);
    });
  }

  void _flickEnd(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    if (speed.abs() < _flick) return;
    _select(current + (speed < 0 ? 1 : -1));
  }

  Widget _edgeZone({required bool left}) => Positioned(
    top: fullPageBackClearance,
    bottom: 0,
    left: left ? 0 : null,
    right: left ? null : 0,
    width: _edge,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: _flickEnd,
    ),
  );

  Widget _body(BuildContext context, Brick brick) =>
      widget.builder(context, brick) ??
      Center(child: Text(brickTitle(context, brick)));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bricks = widget.bricks;
    final brick = bricks[current];
    return FullPage(
      title: widget.title,
      tool: brick.toolId,
      immersive: true,
      scroll: false,
      fallback: '/',
      onBack: widget.onGrid,
      tabs: ToolTabs(
        label: l.sessionToolTabs,
        current: current,
        onSelect: _select,
        items: [
          for (final b in bricks)
            ToolTab(
              id: b.id,
              label: brickTitle(context, b),
              icon: toolIcon(b.toolId),
            ),
        ],
      ),
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft, alt: true): () =>
            _select(current - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight, alt: true): () =>
            _select(current + 1),
      },
      actions: [
        CompanionButton(
          items: [
            for (final b in bricks)
              SwitcherItem(
                id: b.id,
                label: brickTitle(context, b),
                icon: toolIcon(b.toolId),
              ),
          ],
          current: current,
          onSelect: _select,
          tooltip: l.sessionSwitchTool,
          gridLabel: l.sessionGridView,
          onGrid: widget.onGrid,
        ),
      ],
      child: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            sizing: StackFit.expand,
            index: current,
            children: [
              for (final b in bricks)
                visited.contains(b.id)
                    ? KeyedSubtree(
                        key: ValueKey(b.id),
                        child: _body(context, b),
                      )
                    : const SizedBox.shrink(),
            ],
          ),
          _edgeZone(left: true),
          _edgeZone(left: false),
        ],
      ),
    );
  }
}
