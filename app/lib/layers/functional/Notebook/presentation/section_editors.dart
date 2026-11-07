import 'package:flutter/material.dart';

import 'package:amiludo/layers/functional/Notebook/domain/entities/notebook_entry.dart';
import 'package:amiludo/layers/technical/Locale/context_l10n.dart';
import 'package:amiludo/layers/technical/Theme/tokens/design_tokens.dart';

typedef SectionChange = ValueChanged<EntrySection>;

class AddField extends StatefulWidget {
  const AddField({super.key, required this.label, required this.onAdd});
  final String label;
  final ValueChanged<String> onAdd;

  @override
  State<AddField> createState() => _AddFieldState();
}

class _AddFieldState extends State<AddField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: widget.label),
          onSubmitted: (_) => submit(),
        ),
      ),
      IconButton(
        tooltip: widget.label,
        constraints: const BoxConstraints(
          minWidth: Targets.minimum,
          minHeight: Targets.minimum,
        ),
        onPressed: submit,
        icon: const Icon(Icons.add),
      ),
    ],
  );
}

class ChecklistEditor extends StatelessWidget {
  const ChecklistEditor({
    super.key,
    required this.section,
    required this.onChange,
  });
  final EntrySection section;
  final SectionChange onChange;

  @override
  Widget build(BuildContext context) {
    final items = section.items;
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: items[i].done,
            title: Text(
              items[i].text,
              style: items[i].done
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            secondary: IconButton(
              tooltip: context.l10n.notebookRemove,
              onPressed: () =>
                  onChange(section.copyWith(items: [...items]..removeAt(i))),
              icon: const Icon(Icons.close),
            ),
            onChanged: (_) => onChange(
              section.copyWith(
                items: [
                  for (var j = 0; j < items.length; j++)
                    j == i ? items[j].toggled() : items[j],
                ],
              ),
            ),
          ),
        AddField(
          label: context.l10n.notebookAddItem,
          onAdd: (text) => onChange(
            section.copyWith(
              items: [
                ...items,
                CheckItem(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TagsEditor extends StatelessWidget {
  const TagsEditor({super.key, required this.section, required this.onChange});
  final EntrySection section;
  final SectionChange onChange;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: Space.sm,
        children: [
          for (final tag in section.tags)
            InputChip(
              label: Text(tag),
              onDeleted: () => onChange(
                section.copyWith(tags: [...section.tags]..remove(tag)),
              ),
            ),
        ],
      ),
      AddField(
        label: context.l10n.notebookAddTag,
        onAdd: (text) =>
            onChange(section.copyWith(tags: [...section.tags, text])),
      ),
    ],
  );
}
