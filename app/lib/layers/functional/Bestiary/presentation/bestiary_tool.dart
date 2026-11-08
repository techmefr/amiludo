import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amiludo/layers/technical/Theme/deck_widgets.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/entities/bestiary.dart';
import 'package:amiludo/layers/functional/Bestiary/domain/entities/creature.dart';
import 'package:amiludo/layers/functional/Bestiary/presentation/bestiary_texts.dart';
import 'package:amiludo/layers/functional/Bestiary/presentation/creature_card.dart';
import 'package:amiludo/layers/functional/Bestiary/presentation/creature_editor.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/text_input_dialog.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

class BestiaryTool extends StatefulWidget {
  const BestiaryTool({
    super.key,
    this.initial = const Bestiary(),
    this.onChanged,
  });
  final Bestiary initial;
  final ValueChanged<Bestiary>? onChanged;

  @override
  State<BestiaryTool> createState() => _BestiaryToolState();
}

class _BestiaryToolState extends State<BestiaryTool> {
  late Bestiary bestiary = widget.initial;
  final tool = toolThemeFor('bestiary');
  String query = '';
  CreatureKind? kind;
  String? tag;

  void _commit(Bestiary next) {
    setState(() => bestiary = next);
    widget.onChanged?.call(next);
  }

  void _say(String message) => ScaffoldMessenger.maybeOf(
    context,
  )?.showSnackBar(SnackBar(content: Text(message)));

  Future<void> _edit([Creature? creature]) async {
    final saved = await showCreatureEditor(
      context,
      creature: creature,
      onDelete: creature == null
          ? null
          : () => _commit(bestiary.remove(creature.id)),
    );
    if (saved != null) _commit(bestiary.put(saved));
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: bestiary.export()));
    if (mounted) _say(context.l10n.bestiaryCopied);
  }

  Future<void> _import() async {
    final text = await showTextInputDialog(
      context,
      title: context.l10n.bestiaryImport,
      label: context.l10n.bestiaryImportHint,
      confirm: context.l10n.bestiaryImport,
      multiline: true,
    );
    if (text == null || !mounted) return;
    final l = context.l10n;
    final result = bestiary.import(text);
    if (result == null) {
      _say(l.bestiaryImportFailed);
      return;
    }
    _commit(result.merged);
    _say(l.bestiaryImported(result.count));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final shown = bestiary.filter(query: query, kind: kind, tag: tag);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton.icon(
              onPressed: _edit,
              icon: const DeckIcon(Icons.add),
              label: Text(l.bestiaryAdd),
            ),
            OutlinedButton.icon(
              onPressed: bestiary.isEmpty ? null : _copy,
              icon: const DeckIcon(Icons.arrow_outward),
              label: Text(l.bestiaryExport),
            ),
            OutlinedButton.icon(
              onPressed: _import,
              icon: const DeckIcon(Icons.add_chart_outlined),
              label: Text(l.bestiaryImport),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        TextField(
          decoration: InputDecoration(
            labelText: l.bestiarySearch,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.xs,
          children: [
            ChoiceChip(
              label: Text(l.bestiaryAll),
              selected: kind == null,
              onSelected: (_) => setState(() => kind = null),
            ),
            for (final k in CreatureKind.values)
              ChoiceChip(
                avatar: DeckIcon(creatureKindIcon(k), size: 18),
                label: Text(context.creatureKindLabel(k)),
                selected: kind == k,
                onSelected: (_) => setState(() => kind = k),
              ),
          ],
        ),
        if (bestiary.tags.isNotEmpty) ...[
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.xs,
            children: [
              for (final t in bestiary.tags)
                FilterChip(
                  label: Text(t),
                  selected: tag == t,
                  onSelected: (on) => setState(() => tag = on ? t : null),
                ),
            ],
          ),
        ],
        const SizedBox(height: Space.lg),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: Text(
              bestiary.isEmpty ? l.bestiaryEmpty : l.bestiaryNoMatch,
              textAlign: TextAlign.center,
            ),
          ),
        ResponsiveGrid(
          minimumWidth: 360,
          gap: Space.sm,
          children: [
            for (final c in shown)
              CreatureCard(
                key: ValueKey(c.id),
                creature: c,
                tool: tool,
                onOpen: () => _edit(c),
              ),
          ],
        ),
      ],
    );
  }
}
