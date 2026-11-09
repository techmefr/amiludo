import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/full_page.dart';
import 'package:amiludo/layers/technical/Theme/immersive_chrome.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_layout.dart';

class ImmersivePage extends StatelessWidget {
  const ImmersivePage({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.floatingActionButton,
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  void _back(BuildContext context) => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ImmersiveChrome(
      onBack: () => _back(context),
      child: Scaffold(
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: fullPageBackClearance),
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
                top: Space.xs,
                left: Space.xs,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(Targets.minimum),
                    backgroundColor: scheme.surface.withValues(alpha: .55),
                    foregroundColor: scheme.onSurfaceVariant,
                  ),
                  onPressed: () => _back(context),
                  icon: const BackButtonIcon(),
                ),
              ),
              if (actions.isNotEmpty)
                Positioned(
                  top: Space.xs,
                  right: Space.xs,
                  child: Row(children: actions),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
