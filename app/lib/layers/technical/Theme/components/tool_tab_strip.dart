import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/components/tool_bar_scope.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class ToolTabStrip extends StatefulWidget {
  const ToolTabStrip({super.key, required this.tabs});
  final ToolTabs tabs;

  @override
  State<ToolTabStrip> createState() => _ToolTabStripState();
}

class _ToolTabStripState extends State<ToolTabStrip> {
  late List<GlobalKey> keys = _keys();

  List<GlobalKey> _keys() => [for (final _ in widget.tabs.items) GlobalKey()];

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(ToolTabStrip old) {
    super.didUpdateWidget(old);
    if (old.tabs.items.length != widget.tabs.items.length) keys = _keys();
    if (old.tabs.current != widget.tabs.current) _reveal();
  }

  void _reveal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || widget.tabs.current >= keys.length) return;
    final target = keys[widget.tabs.current].currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      alignment: .5,
      duration: Motion.of(context, Motion.base),
    );
  });

  Widget _tab(BuildContext context, int index) {
    final scheme = Theme.of(context).colorScheme;
    final item = widget.tabs.items[index];
    final selected = index == widget.tabs.current;
    final foreground = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    return Semantics(
      key: keys[index],
      button: true,
      selected: selected,
      label: item.label,
      child: ExcludeSemantics(
        child: Material(
          color: selected
              ? scheme.primaryContainer
              : scheme.surface.withValues(alpha: .55),
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => widget.tabs.onSelect(index),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: Targets.minimum,
                minWidth: Targets.minimum,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      DeckIcon(item.icon!, color: foreground),
                      const SizedBox(width: Space.xs),
                    ],
                    Text(
                      item.label,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: widget.tabs.label,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      primary: false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.tabs.items.length; i++) ...[
            if (i > 0) const SizedBox(width: Space.xs),
            _tab(context, i),
          ],
        ],
      ),
    ),
  );
}
