import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tool_badge.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/components/tool_tab_strip.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ToolTopBar extends StatelessWidget {
  const ToolTopBar({
    super.key,
    required this.onBack,
    this.tool,
    this.tabs,
    this.actions = const [],
  });
  final VoidCallback onBack;
  final String? tool;
  final ToolTabs? tabs;
  final List<Widget> actions;

  Widget _back(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return tool == null
        ? IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            style: IconButton.styleFrom(
              minimumSize: const Size.square(Targets.minimum),
              backgroundColor: scheme.surface.withValues(alpha: .55),
              foregroundColor: scheme.onSurfaceVariant,
            ),
            onPressed: onBack,
            icon: const BackButtonIcon(),
          )
        : ToolHeaderPill(id: tool!, onBack: onBack);
  }

  Widget _row(BuildContext context, ToolBarController? controller) {
    final inner = controller?.tabs;
    return Row(
      children: [
        _back(context),
        const SizedBox(width: Space.xs),
        if (tabs != null) Expanded(child: ToolTabStrip(tabs: tabs!)),
        if (inner != null) ...[
          if (tabs != null) const SizedBox(width: Space.xs),
          Expanded(child: ToolTabStrip(tabs: inner)),
        ],
        if (tabs == null && inner == null) const Spacer(),
        ...?controller?.actions,
        ...actions,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ToolBarScope.maybeOf(context);
    return Padding(
      padding: const EdgeInsets.all(Space.xs),
      child: controller == null
          ? _row(context, null)
          : ListenableBuilder(
              listenable: controller,
              builder: (context, _) => _row(context, controller),
            ),
    );
  }
}
