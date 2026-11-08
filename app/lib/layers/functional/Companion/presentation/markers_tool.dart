import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

const _tokens = ['monarch', 'first', 'initiative'];

class MarkersTool extends StatefulWidget {
  const MarkersTool({super.key, required this.names});
  final List<String> names;

  @override
  State<MarkersTool> createState() => _MarkersToolState();
}

class _MarkersToolState extends State<MarkersTool> {
  final Map<String, int> holders = {};
  final tool = toolThemeFor('markers');

  String _label(BuildContext context, String id) => switch (id) {
    'first' => context.l10n.markerFirst,
    'initiative' => context.l10n.markerInitiative,
    _ => context.l10n.markerMonarch,
  };

  void _give(String token, int player) {
    tool.signal();
    setState(() {
      if (holders[token] == player) {
        holders.remove(token);
      } else {
        holders[token] = player;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final token in _tokens) ...[
          Text(_label(context, token), style: theme.titleMedium),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final (i, name) in widget.names.indexed)
                ChoiceChip(
                  avatar: holders[token] == i
                      ? const Icon(Icons.workspace_premium, size: 18)
                      : null,
                  label: Text(name),
                  selected: holders[token] == i,
                  onSelected: (_) => _give(token, i),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
        ],
      ],
    );
  }
}
