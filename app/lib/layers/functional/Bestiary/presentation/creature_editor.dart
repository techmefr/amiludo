import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Bestiary/domain/entities/creature.dart';
import 'package:amiludo/layers/functional/Bestiary/presentation/bestiary_texts.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/deck_icon.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

Future<Creature?> showCreatureEditor(
  BuildContext context, {
  Creature? creature,
  VoidCallback? onDelete,
}) => showModalBottomSheet<Creature>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => CreatureEditor(creature: creature, onDelete: onDelete),
);

class CreatureEditor extends StatefulWidget {
  const CreatureEditor({super.key, this.creature, this.onDelete});
  final Creature? creature;
  final VoidCallback? onDelete;

  @override
  State<CreatureEditor> createState() => _CreatureEditorState();
}

typedef _FieldControllers = ({
  TextEditingController label,
  TextEditingController value,
});

class _CreatureEditorState extends State<CreatureEditor> {
  late final name = TextEditingController(text: widget.creature?.name);
  late final tags = TextEditingController(
    text: widget.creature?.tags.join(', '),
  );
  late final notes = TextEditingController(text: widget.creature?.notes);
  late CreatureKind kind = widget.creature?.kind ?? CreatureKind.monster;
  final List<_FieldControllers> fields = [];

  @override
  void initState() {
    super.initState();
    final known = widget.creature?.fields;
    if (known != null) {
      for (final f in known) {
        fields.add(_row(f.label, f.value));
      }
    }
  }

  _FieldControllers _row(String label, String value) => (
    label: TextEditingController(text: label),
    value: TextEditingController(text: value),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.creature == null && fields.isEmpty) {
      final l = context.l10n;
      for (final label in [
        l.bestiaryFieldDefense,
        l.bestiaryFieldAttack,
        l.bestiaryFieldSpeed,
        l.bestiaryFieldSpecial,
      ]) {
        fields.add(_row(label, ''));
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    tags.dispose();
    notes.dispose();
    for (final f in fields) {
      f.label.dispose();
      f.value.dispose();
    }
    super.dispose();
  }

  void _save() {
    final clean = name.text.trim();
    if (clean.isEmpty) return;
    Navigator.pop(
      context,
      Creature(
        id: widget.creature?.id ?? newCreatureId(),
        name: clean,
        kind: kind,
        tags: [
          for (final t in tags.text.split(','))
            if (t.trim().isNotEmpty) t.trim(),
        ],
        fields: [
          for (final f in fields)
            if (f.label.text.trim().isNotEmpty || f.value.text.trim().isNotEmpty)
              CreatureField(f.label.text.trim(), f.value.text.trim()),
        ],
        notes: notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final title = Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: l.combatName),
            ),
            const SizedBox(height: Space.md),
            Wrap(
              spacing: Space.sm,
              children: [
                for (final k in CreatureKind.values)
                  ChoiceChip(
                    avatar: DeckIcon(creatureKindIcon(k), size: 18),
                    label: Text(context.creatureKindLabel(k)),
                    selected: kind == k,
                    onSelected: (_) => setState(() => kind = k),
                  ),
              ],
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: tags,
              decoration: InputDecoration(labelText: l.bestiaryTags),
            ),
            const SizedBox(height: Space.lg),
            Text(l.bestiaryFields, style: title),
            for (final (i, f) in fields.indexed)
              Padding(
                padding: const EdgeInsets.only(top: Space.sm),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: f.label,
                        decoration: InputDecoration(
                          labelText: l.bestiaryFieldLabel,
                        ),
                      ),
                    ),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: f.value,
                        decoration: InputDecoration(
                          labelText: l.bestiaryFieldValue,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l.bestiaryRemoveField(f.label.text),
                      onPressed: () => setState(() => fields.removeAt(i)),
                      icon: const DeckIcon(Icons.close),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => fields.add(_row('', ''))),
                icon: const DeckIcon(Icons.add),
                label: Text(l.bestiaryAddField),
              ),
            ),
            const SizedBox(height: Space.md),
            TextField(
              controller: notes,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(labelText: l.bestiaryNotes),
            ),
            const SizedBox(height: Space.lg),
            FilledButton(onPressed: _save, child: Text(l.bestiarySave)),
            if (widget.onDelete != null)
              TextButton(
                onPressed: () {
                  widget.onDelete!();
                  Navigator.pop(context);
                },
                child: Text(l.bestiaryDelete),
              ),
          ],
        ),
      ),
    );
  }
}
