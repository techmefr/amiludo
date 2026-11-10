import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/aura/aura_background.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_top_bar.dart';
import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/immersive_chrome.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';

class ImmersivePage extends StatelessWidget {
  const ImmersivePage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.tabs,
    this.floatingActionButton,
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  final ToolTabs? tabs;
  final Widget? floatingActionButton;

  void _back(BuildContext context) => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) => ImmersiveChrome(
    onBack: () => _back(context),
    child: ToolBarHost(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: AuraBackground()),
          Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: floatingActionButton,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: fullPageBackClearance,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: ToolLayout.maxWidth(context),
                          ),
                          child: child,
                        ),
                      ),
                    ),
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
                    child: ToolTopBar(
                      tabs: tabs,
                      actions: actions,
                      onBack: () => _back(context),
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
