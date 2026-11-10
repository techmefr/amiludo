import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_background.dart';
import 'package:amiludo/layers/technical/Theme/components/clean_scroll_page.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_top_bar.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_frame.dart';
import 'package:amiludo/layers/technical/Theme/deck_style.dart';
import 'package:amiludo/layers/technical/Theme/immersive_chrome.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';

const double fullPageBackClearance = toolBackClearance;

class FullPage extends StatelessWidget {
  const FullPage({
    super.key,
    required this.title,
    required this.child,
    this.fallback = '/tools',
    this.scroll = true,
    this.actions = const [],
    this.maxWidth,
    this.fillHeight = false,
    this.immersive = false,
    this.bleed = false,
    this.tabs,
    this.tool,
    this.background,
    this.onBack,
    this.bindings = const {},
    this.bottomBar,
  });
  final String title, fallback;
  final String? tool;
  final Widget child;
  final Color? background;
  final bool scroll, fillHeight, immersive, bleed;
  final ToolTabs? tabs;
  final VoidCallback? onBack;
  final Map<ShortcutActivator, VoidCallback> bindings;
  final double? maxWidth;
  final List<Widget> actions;
  final Widget? bottomBar;

  static const double _padding = 20;
  static const double _backClearance = fullPageBackClearance;

  void _back(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallback);
    }
  }

  Widget _body(BuildContext context) {
    if (bleed) return child;
    if (!scroll) {
      return immersive
          ? Padding(
              padding: const EdgeInsets.only(top: _backClearance),
              child: child,
            )
          : child;
    }
    final top = immersive ? _backClearance : _padding;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(_padding, top, _padding, _padding),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? ToolLayout.maxWidth(context),
              minHeight: fillHeight
                  ? (constraints.maxHeight - top - _padding).clamp(
                      0,
                      double.infinity,
                    )
                  : 0,
            ),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _page(context);
    return tool == null ? page : ToolFrame(id: tool!, child: page);
  }

  Widget _page(BuildContext context) {
    if (immersive) {
      return ImmersiveChrome(
        onBack: () => _back(context),
        bindings: bindings,
        child: ToolBarHost(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (tool == null && background == null)
                const Positioned.fill(child: AuraBackground()),
              AnimatedContainer(
                duration: Motion.of(context, Motion.slow),
                curve: Motion.curve,
                color: background ?? Colors.transparent,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: bleed
                            ? _body(context)
                            : SafeArea(child: _body(context)),
                      ),
                      Semantics(
                        header: true,
                        label: title,
                        child: const SizedBox.shrink(),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          bottom: false,
                          child: ToolTopBar(
                            tool: tool,
                            tabs: tabs,
                            actions: actions,
                            onBack: () => _back(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (scroll && Theme.of(context).extension<DeckStyle>()?.clean == true) {
      return CleanScrollPage(
        title: title,
        onBack: () => _back(context),
        actions: actions,
        maxWidth: maxWidth ?? 760,
        fillHeight: fillHeight,
        bottomBar: bottomBar,
        child: child,
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _back(context)),
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(child: _body(context)),
    );
  }
}
