import 'package:flutter/material.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Rules/domain/entities/rule_book.dart';
import 'package:amiludo/layers/functional/Rules/presentation/rule_decisions_sheet.dart';
import 'package:amiludo/layers/functional/Rules/presentation/rule_section_card.dart';
import 'package:amiludo/layers/functional/Rules/presentation/rule_section_dialog.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/text_prompt.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

class RulesTool extends StatefulWidget {
  const RulesTool({
    super.key,
    this.initial = const RuleBook(),
    this.onChanged,
    this.askName,
  });
  final RuleBook initial;
  final ValueChanged<RuleBook>? onChanged;
  final Future<String?> Function(BuildContext context)? askName;

  @override
  State<RulesTool> createState() => _RulesToolState();
}

class _RulesToolState extends State<RulesTool> {
  late RuleBook book = widget.initial;
  String? selectedId;
  String query = '';
  bool table = false;

  RuleGame? get game => book.of(selectedId) ?? book.games.firstOrNull;

  void _commit(RuleBook next) {
    setState(() => book = next);
    widget.onChanged?.call(next);
  }

  Future<void> _newGame() async {
    final ask =
        widget.askName ??
        (BuildContext c) =>
            textPrompt(c, c.l10n.rulesNewGame, label: c.l10n.rulesGameName);
    final name = (await ask(context))?.trim() ?? '';
    if (!mounted || name.isEmpty) return;
    final created = RuleGame(id: newRuleId(), name: name);
    _commit(book.put(created));
    setState(() => selectedId = created.id);
  }

  Future<void> _editSection(RuleGame current, int index) async {
    final existing = index < current.sections.length
        ? current.sections[index]
        : null;
    final section = await editRuleSection(context, initial: existing);
    if (!mounted || section == null) return;
    _commit(book.put(current.withSection(index, section)));
  }

  Future<void> _deleteGame(RuleGame current) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.rulesDeleteGame),
        content: Text(current.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.themeCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.randomDelete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _commit(book.remove(current.id));
    setState(() => selectedId = null);
  }

  Widget _games(RuleGame? current) => Wrap(
    spacing: Space.sm,
    runSpacing: Space.sm,
    children: [
      for (final g in book.games)
        ChoiceChip(
          label: Text(g.name),
          selected: g.id == current?.id,
          onSelected: (_) => setState(() => selectedId = g.id),
        ),
      ChoiceChip(
        avatar: const DeckIcon(Icons.public),
        label: Text(context.l10n.rulesCommon),
        selected: current?.id == commonRuleId,
        onSelected: (_) => setState(() => selectedId = commonRuleId),
      ),
      ActionChip(
        avatar: const DeckIcon(Icons.add),
        label: Text(context.l10n.rulesNewGame),
        onPressed: _newGame,
      ),
    ],
  );

  Widget _toolbar() => Row(
    children: [
      Expanded(
        child: TextField(
          onChanged: (v) => setState(() => query = v),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.l10n.rulesSearch,
            prefixIcon: const DeckIcon(Icons.search),
          ),
        ),
      ),
      const SizedBox(width: Space.sm),
      IconButton.filledTonal(
        tooltip: context.l10n.rulesTableMode,
        isSelected: table,
        onPressed: () => setState(() => table = !table),
        icon: const DeckIcon(Icons.table_restaurant_outlined),
      ),
    ],
  );

  List<Widget> _sections(RuleGame current) {
    final l = context.l10n;
    final shown = current.search(query);
    if (current.sections.isEmpty) {
      return [Text(l.rulesNoSection)];
    }
    if (shown.isEmpty) return [Text(l.rulesNoMatch)];
    return [
      ResponsiveGrid(
        minimumWidth: 420,
        gap: Space.md,
        children: [
          for (final i in shown)
            RuleSectionCard(
              section: current.sections[i],
              table: table,
              onEdit: () => _editSection(current, i),
              onDelete: () => _commit(book.put(current.withoutSection(i))),
            ),
        ],
      ),
    ];
  }

  Widget _commonSections(RuleGame current) {
    final shown = book.commonGame.search(query);
    if (current.id == commonRuleId || shown.isEmpty) {
      return const SizedBox.shrink();
    }
    return ExpansionTile(
      title: Text(context.l10n.rulesCommonCount(shown.length)),
      initiallyExpanded: query.isNotEmpty,
      children: [
        for (final i in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: RuleSectionCard(
              section: book.common[i],
              table: table,
              onEdit: () => setState(() => selectedId = commonRuleId),
              onDelete: () =>
                  _commit(book.put(book.commonGame.withoutSection(i))),
            ),
          ),
      ],
    );
  }

  Widget _actions(RuleGame current) => Wrap(
    spacing: Space.md,
    runSpacing: Space.md,
    children: [
      FilledButton.icon(
        onPressed: () => _editSection(current, current.sections.length),
        icon: const DeckIcon(Icons.add),
        label: Text(context.l10n.rulesAddSection),
      ),
      if (current.id != commonRuleId)
        OutlinedButton.icon(
        onPressed: () => showRuleDecisions(
          context,
          game: current,
          onChanged: (next) => _commit(book.put(next)),
        ),
        icon: const DeckIcon(Icons.gavel_outlined),
        label: Text(context.l10n.rulesDecisions(current.decisions.length)),
      ),
      if (current.id != commonRuleId)
        TextButton.icon(
        onPressed: () => _deleteGame(current),
        icon: const DeckIcon(Icons.delete_outline),
        label: Text(context.l10n.rulesDeleteGame),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final current = game;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (current == null) ...[
              Text(context.l10n.rulesEmpty),
              const SizedBox(height: Space.lg),
              _games(null),
            ] else ...[
              _games(current),
              const SizedBox(height: Space.lg),
              _toolbar(),
              const SizedBox(height: Space.lg),
              ..._sections(current),
              _commonSections(current),
              if (!table) ...[const SizedBox(height: Space.md), _actions(current)],
            ],
          ],
        ),
      ),
    );
  }
}
