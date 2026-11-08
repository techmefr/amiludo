import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';

const _free = '';
const _builder = '#builder';
const _market = '#market';

class ToolConfigMenu extends StatelessWidget {
  const ToolConfigMenu({
    super.key,
    required this.current,
    required this.packs,
    required this.onSelect,
  });
  final GameTemplate? current;
  final List<GameTemplate> packs;
  final ValueChanged<String> onSelect;

  void _chosen(BuildContext context, String value) {
    switch (value) {
      case _builder:
        context.push(
          current == null ? '/builder/new' : '/builder/${current!.id}',
        );
      case _market:
        context.push('/marketplace');
      default:
        onSelect(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final chosen = current?.id ?? _free;
    return PopupMenuButton<String>(
      tooltip: l.randomGameSetup,
      icon: const DeckIcon(Icons.tune),
      onSelected: (value) => _chosen(context, value),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: _free,
          checked: chosen == _free,
          child: Text(l.randomFreeTool),
        ),
        for (final p in packs)
          CheckedPopupMenuItem(
            value: p.id,
            checked: chosen == p.id,
            child: Text(p.name),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(value: _builder, child: Text(l.randomOpenTheBuilder)),
        PopupMenuItem(value: _market, child: Text(l.randomFindAPack)),
      ],
    );
  }
}
